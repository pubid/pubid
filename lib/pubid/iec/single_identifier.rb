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

        # IEC house style separates the publisher from the typed-stage
        # abbreviation with a SPACE, for every type and whether or not there
        # are copublishers: "IEC CD 60038", "IEC PNW 1000-1:2023". The slash
        # stays the copublisher separator only. The slash input spelling
        # ("IEC/CD 60038") is still accepted by the parser; only rendering
        # normalises. See issue #360 item 2.
        abbr = typed_stage&.abbreviation.to_s
        pub_string += " #{abbr}" unless abbr.empty?

        pub_string
      end

      def number_portion(lang_single: false)
        [
          (number ? number.to_s : ""),
          (part ? "-#{part}" : ""),
          (subpart ? "-#{subpart}" : ""),
          (stage_iteration ? ".#{stage_iteration}" : ""),
          (date ? ":#{date.render}" : ""),
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
