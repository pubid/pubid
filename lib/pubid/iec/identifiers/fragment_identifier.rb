require_relative "../identifier"
# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Fragment Identifier
      # Single Responsibility: Represents a specific fragment/part within an Amendment or Corrigendum
      # Example: "IEC 60050-191/AMD2/FRAG2 ED1" = Fragment 2 of Amendment 2
      class FragmentIdentifier < Identifier
        attribute :base_identifier, Identifier, polymorphic: true
        attribute :fragment_number, :string
        attribute :edition, ::Pubid::Components::Edition, default: -> {}

        def to_s(lang: :en, lang_single: false, with_edition: false)
          parts = []

          # Render base identifier (the amendment/corrigendum)
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single,
                                        with_edition: with_edition)

          # Add fragment notation /FRAGN or /FRAGCN depending on base type
          parts << if base_identifier.is_a?(Identifiers::Corrigendum)
                     "/FRAGC#{fragment_number}"
                   else
                     "/FRAG#{fragment_number}"
                   end

          # Add edition if present
          parts << " #{edition}" if edition&.number

          parts.join
        end

        # Delegate common attributes to base_identifier
        def publisher
          base_identifier&.publisher
        end

        def copublishers
          base_identifier&.copublishers
        end

        def number
          base_identifier&.number
        end

        def date
          base_identifier&.date
        end

        def type
          :fragment
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
