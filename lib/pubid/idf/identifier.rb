# frozen_string_literal: true

module Pubid
  # Identifier that
  module Idf
    # An IDF identifier has no copublisher
    class Identifier < ::Pubid::Identifier
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [
          publisher_portion(lang: lang),
          number_portion(lang_single: lang_single),
        ].join
      end

      def publisher_portion(lang: :en)
        [
          publisher.body,
          (typed_stage.abbreviation.empty? ? "" : "/#{typed_stage.abbreviation}"),
        ].join
      end

      def number_portion(lang_single: false)
        [
          # Directives may not have a number
          (number ? " #{number.value}" : ""),

          # Parts and subparts are optional
          (part ? "-#{part.value}" : ""),
          (subpart ? "-#{subpart.value}" : ""),

          # Stage iteration is optional
          (stage_iteration ? ".#{stage_iteration.value}" : ""),

          # Date is optional
          (date ? ":#{date.year}" : ""),

          # Languages are optional
          language_portion(lang_single: lang_single),
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

      def self.parse(string)
        parsed = Pubid::Idf::Parser.new.parse(string)
        if parsed.nil? || parsed.empty?
          raise Pubid::Idf::Parser::ParseError,
                "Invalid identifier format"
        end

        Pubid::Idf::Builder.new.build(parsed)
      end

      # Factory mirroring pubid 1.x's `Pubid::Idf::Identifier.create` API.
      # Default subclass is {Identifiers::InternationalStandard}.
      #
      # IDF's renderer requires `typed_stage` to be set (calls
      # `.abbreviation` without a nil check); factory auto-resolves the
      # "published" TypedStage for the chosen subclass.
      TYPE_KEY_TO_KLASS = {
        is:              "InternationalStandard",
        reviewed_method: "ReviewedMethod",
      }.freeze

      def self.create(type: nil, stage: nil, **opts)
        klass = resolve_create_class(type)
        attrs = coerce_create_attrs(opts)
        ts = resolve_create_typed_stage(klass, stage)
        attrs[:typed_stage] = ts if ts
        klass.new(**attrs)
      end

      def self.resolve_create_class(type)
        return Identifiers::InternationalStandard if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown IDF type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.resolve_create_typed_stage(klass, stage)
        return nil unless klass.const_defined?(:TYPED_STAGES)

        if stage
          klass.const_get(:TYPED_STAGES).find do |ts|
            ts.abbr.include?(stage.to_s)
          end
        else
          klass.const_get(:TYPED_STAGES).find do |ts|
            ts.stage_code&.to_sym == :published
          end
        end
      end

      def self.coerce_create_attrs(opts)
        attrs = {
          publisher: Pubid::Components::Publisher.new(
            body: (opts[:publisher] || "IDF").to_s,
          ),
        }
        if (v = opts[:number])
          attrs[:number] = Pubid::Components::Code.new(value: v.to_s)
        end
        if (v = opts[:year])
          attrs[:date] = Pubid::Components::Date.new(year: v.to_s)
        end
        attrs
      end
      private_class_method :resolve_create_class,
                           :resolve_create_typed_stage,
                           :coerce_create_attrs
    end
  end
end
