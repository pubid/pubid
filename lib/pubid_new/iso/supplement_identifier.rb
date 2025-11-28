require_relative "identifier"

module PubidNew
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << [
            base_identifier.to_s(lang: lang, lang_single: lang_single, with_edition: with_edition),
            "/#{typed_stage.canonical_abbreviation}",
          ].join('')
          # Only add space if abbreviation doesn't end with a period
          parts << (typed_stage.canonical_abbreviation.end_with?('.') ? '' : ' ')
          parts << number_portion(lang_single: lang_single)

          parts << ' ' + edition_portion(lang: lang) if with_edition && edition&.number
          parts << language_portion(lang_single: lang_single) if languages&.any?
        end.compact.join('')
      end

      # Generate URN for supplement with recursive base handling
      # Format: {base_urn}[:edition][:stage]:{supplement_type}:{year}:v{number}[:language]
      # @param include_stage [Boolean] whether to include stage in base identifier URN (for multi-level supplements)
      def to_urn(include_stage: true)
        parts = []
        
        # Base identifier URN (recursive - handles multi-level supplements)
        # When supplement has a stage, exclude base's stage (supplement stage takes precedence)
        if base_identifier
          if stage_urn
            # Supplement has a stage - get base URN without its stage
            parts << base_identifier.to_urn(include_stage: false)
          else
            # Supplement doesn't have a stage - include base's stage if present
            parts << base_identifier.to_urn(include_stage: include_stage)
          end
        end
        
        # Edition (for supplements with edition)
        parts << edition_urn if edition && edition.number
        
        # Stage (for supplements with draft stages like CD Amd, FDAM, etc.)
        # This is the supplement's own stage, which takes precedence over base's stage
        parts << stage_urn if stage_urn
        
        # Supplement type code (amd, cor, add, etc.)
        # Use urn_supplement_type override if available (for Addendum/Supplement -> 'sup')
        # Otherwise use typed_stage.type_code (for Amendment -> 'amd', Corrigendum -> 'cor')
        if typed_stage
          parts << (respond_to?(:urn_supplement_type) ? urn_supplement_type : typed_stage.type_code)
        end
        
        # Year (if present, otherwise use number as identifier)
        if date
          parts << date.year.to_s
          # Version number with "v" prefix (can include iteration like v1.2)
          if stage_iteration
            parts << "v#{number.value}.#{stage_iteration.value}" if number
          else
            parts << "v#{number.value}" if number
          end
        else
          # Without year, use number directly
          parts << number.value if number
          # Version with iteration if present (e.g., v1.2)
          if stage_iteration
            parts << "v1.#{stage_iteration.value}"
          else
            parts << "v1"
          end
        end
        
        # Language (if present)
        if languages&.any?
          parts << languages.map(&:code).join(",")
        end
        
        parts.join(":")
      end

      private

      def edition_urn
        return nil unless edition && edition.number
        "ed-#{edition.number}"
      end

      def stage_urn
        # Only add stage for non-published supplements (e.g., CD Amd, FDAM, DAM)
        return nil if typed_stage.stage_code == "published"
        
        # Get harmonized stage code from typed_stage
        harmonized_code = typed_stage.harmonized_stages&.first
        return nil unless harmonized_code
        
        # Stage without iteration (iteration goes in version number)
        "stage-#{harmonized_code}"
      end
    end
  end
end
