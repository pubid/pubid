require_relative "identifier"
# frozen_string_literal: true
require_relative "../components/typed_stage"
require_relative "urn_generator"

module Pubid
  module Iec
    class SingleIdentifier < Identifier
      attribute :typed_stage, Components::TypedStage

      # Generate URN for this identifier
      #
      # @return [String] URN representation
      def to_urn
        UrnGenerator.new(self).generate
      end

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << publisher_portion(lang: lang)
          parts << number_portion(lang_single: lang_single)
          parts << edition_portion(lang: lang) if with_edition
        end.compact.join(" ").tap do |s|
          s << language_portion(lang_single: lang_single) if languages&.any?
        end
      end

      def publisher_portion(lang: :en)
        # IEC identifiers can have copublishers (e.g., IEC/IEEE, ISO/IEC)

        # Build publisher string
        pub_string = if copublishers&.any?
                       # Has copublishers: "IEC/IEEE" or "ISO/IEC"
                       ([publisher] + copublishers).map(&:body).join("/")
                     else
                       # No copublishers: just "IEC"
                       publisher.body
                     end

        # Add type abbreviation if present
        if typed_stage && !typed_stage.abbreviation.empty?
          abbr = typed_stage.abbreviation
          # For copublishers or empty abbr, use space; otherwise use slash
          pub_string += if copublishers&.any? || abbr == ""
                          (abbr == "" ? "" : " #{abbr}")
                        else
                          "/#{abbr}"
                        end
        end

        pub_string
      end

      def number_portion(lang_single: false)
        [
          (number ? "#{number}" : ""),
          (part ? "-#{part}" : ""),
          (subpart ? "-#{subpart}" : ""),
          (stage_iteration ? ".#{stage_iteration}" : ""),
          (date ? ":#{date.year}" : ""),
        ].join("")
      end

      def language_portion(lang_single: false)
        return "" unless languages&.any?

        [
          "(",
          languages.map do |lang|
            lang.to_s(lang_single: lang_single)
          end.join(lang_single ? "/" : ","),
          ")",
        ].join("")
      end

      def edition_portion(lang: :en)
        return nil unless edition&.number

        "ED#{edition.number}"
      end
    end
  end
end
