require_relative "../identifier"

module PubidNew
  module Iec
    module Identifiers
      # Sheet Identifier
      # Single Responsibility: Wraps another identifier with sheet number and year
      # Example: "IEC 60695-2-1/1:1994" = Sheet 1 of IEC 60695-2-1 from 1994
      class SheetIdentifier < Identifier
        attribute :base_identifier, Identifier, polymorphic: true
        attribute :sheet_number, :string
        attribute :year, :string, default: -> {}

        def to_s(lang: :en, lang_single: false, with_edition: false)
          parts = []

          # Render base identifier
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single,
                                        with_edition: with_edition)

          # Add sheet notation /N
          parts << "/#{sheet_number}"

          # Add year if present
          parts << ":#{year}" if year

          parts.join
        end

        # Delegate common attributes to base_identifier
        def publisher
          base_identifier&.publisher
        end

        def copublishers
          base_identifier&.copublishers
        end

        def code
          base_identifier&.code
        end

        def number
          base_identifier&.number
        end

        def date
          base_identifier&.date
        end

        def type
          :sheet
        end

        def stage
          base_identifier&.stage
        end

        def typed_stage
          base_identifier&.typed_stage
        end
      end
    end
  end
end
