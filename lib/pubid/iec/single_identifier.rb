# frozen_string_literal: true

module Pubid
  module Iec
    class SingleIdentifier < Identifier
      # Default to the class's published typed_stage so an omitted "stage" key
      # reconstructs the published state on from_hash.
      attribute :typed_stage, ::Pubid::Components::TypedStage,
                default: -> { self.class.published_typed_stage }

      # Generate URN for this identifier
      #
      # @return [String] URN representation

      def to_s(**opts)
        render(format: :human, **opts)
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
          (number ? number.to_s : ""),
          (part ? "-#{part}" : ""),
          (subpart ? "-#{subpart}" : ""),
          (stage_iteration ? ".#{stage_iteration}" : ""),
          (date ? ":#{date.year}" : ""),
        ].join
      end

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
        return nil unless edition&.number

        "ED#{edition.number}"
      end
    end
  end
end
