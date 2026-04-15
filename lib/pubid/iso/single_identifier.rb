# frozen_string_literal: true

require_relative "rendering_style"

module Pubid
  # Identifier that
  module Iso
    class SingleIdentifier < Identifier
      attribute :typed_stage, ::Pubid::Components::TypedStage
      attribute :all_parts, ::Lutaml::Model::Type::Boolean, default: false
      # When the URN parser sees an explicit stage segment (e.g.
      # "stage-published", "stage-60.60"), it stores the original token here so
      # the URN generator can emit it back. Without this, harmonized 60.x and
      # :published stages get normalized away because stage_component returns
      # nil for them. String-parsed identifiers leave this nil and behave the
      # same as before.
      attribute :urn_explicit_stage, ::Lutaml::Model::Type::String

      # Set by the URN parser when an explicit `ed-N` segment was consumed.
      # Tells `to_s` to render the edition by default — V2's default is
      # `with_edition: false`, but URN-sourced identifiers should round-trip
      # back to the same shape (`ISO 10033-1 ED1` etc.). String-parsed
      # identifiers leave this false and keep V2's default behavior.
      attribute :urn_explicit_edition, ::Lutaml::Model::Type::Boolean,
                default: false

      # Rendering style is a strategy object, not serializable data
      attr_accessor :rendering_style

      def initialize(**args)
        super
        # Default rendering style is RefDatedLong (long format with date, matching V1 default)
        @rendering_style ||= RefDatedLong.new
      end

      def to_s(lang: :en, lang_single: false, with_edition: false, format: nil,
stage_format_long: nil, with_date: nil)
        # URN-sourced identifiers default to rendering their edition so the
        # round-trip back through `to_s` preserves the "ISO N-N EDx" form.
        # String-parsed identifiers keep `with_edition: false` as the V2
        # default. The caller's explicit `with_edition: true` always wins;
        # `false` (the default) is upgraded only when the URN parser flagged
        # the edition as explicit.
        with_edition = true if !with_edition && urn_explicit_edition && edition

        # If format is provided, create appropriate rendering style
        if format
          style = RenderingStyle.from_format(format)
          return style.render(self, with_edition: with_edition)
        end

        # If individual parameters are provided, override defaults
        if stage_format_long || with_date || lang_single
          # Use current style's settings as base
          style = RenderingStyle.new(
            with_language_code: lang_single ? :single : (rendering_style&.with_language_code || :none),
            stage_format_long: stage_format_long.nil? ? (rendering_style&.stage_format_long || false) : stage_format_long,
            with_date: with_date.nil? ? (rendering_style&.with_date || true) : with_date,
          )
          return style.render(self, with_edition: with_edition)
        end

        # Otherwise use stored rendering_style
        rendering_style.render(self, with_edition: with_edition)
      end

      def publisher_portion(lang: :en, stage_format_long: true)
        # TODO: implement language-dependent publisher portion
        # The pattern is language-dependent:
        # - the name of the type (e.g., "Guide") may appear before or after the main publisher
        # - the name of the copublisher differs (IEC is "IEC" in English, "CEI" in French)
        # - the order of languages in the language code list differ (priroritize the main language first)

        # English: "ISO/IEC Guide 51:1999(E/F/R)"
        # French: "Guide ISO/CEI 51:1999(F/E/R)"

        abbr = typed_stage ? typed_stage.abbreviation(format_long: stage_format_long) : ""

        # If there are no copublishers, just return the main publisher and type
        unless copublishers&.any?
          return [
            publisher.body,
            (abbr.empty? ? "" : "/#{abbr}"),
          ].join
        end

        # If there are copublishers, join them with slashes
        [
          ([publisher] + copublishers).map(&:body).join("/"),
          (abbr.empty? ? "" : " #{abbr}"),
        ].join
      end

      # def publisher_portion_en
      #   # English: "ISO/IEC Guide 51:1999(E/F/R)"
      #   [
      #     publisher.body,
      #     (type.abbr.empty? ? "" : "/#{type.abbr}")
      #   ].join('') unless copublishers&.any?

      #   # If there are copublishers, join them with slashes
      #   [
      #     ([publisher] + copublishers).map(&:body).join("/"),
      #     (stage ? " #{stage.abbr}" : "")
      #   ].join('')
      # end

      def number_portion(lang_single: false, with_date: true)
        [
          # Directives may not have a number
          (number ? number.value.to_s : ""),

          # Parts and subparts are optional
          (part ? "-#{part.value}" : ""),
          (subpart ? "-#{subpart.value}" : ""),

          # Stage iteration is optional
          (stage_iteration ? ".#{stage_iteration.value}" : ""),

          # Date is optional and controlled by with_date parameter
          (date && with_date ? ":#{date.year}" : ""),
        ].join
      end

      # Returns a string representation of the languages
      # :single returns single-char language codes
      def language_portion(lang_single: false)
        return "" unless languages&.any?

        [
          "(",
          languages.map do |lang|
            lang.to_s(lang_single: lang_single)
          end.join(lang_single ? "/" : ","),
          ")",
        ].join
      end

      def edition_portion(lang: :en)
        return nil unless edition && (edition.number || edition.original_text)

        # Use the edition's to_s method which preserves original format
        edition.to_s
      end

      # Generate URN according to RFC 5141-bis
      #
      # @return [String] The generated URN in RFC 5141-bis format
      def to_urn
        UrnGenerator.new(self).generate
      end
    end
  end
end
