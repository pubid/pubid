require_relative "stage"
require_relative "type"

module PubidNew
  module Components
    class TypedStage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :type_code, :string
      attribute :stage_code, :string
      attribute :abbr, :string, collection: true
      attribute :harmonized_stages, :string, collection: true
      attribute :original_abbr, :string  # Store the actual parsed abbreviation
      attribute :short_abbr, :string  # Short form: DAM, COR, FDAM
      attribute :long_abbr, :string   # Long form: DAmd, Cor, FDAmd

      def to_stage
        Stage.new(
          name: name,
          stage_code: stage_code,
          abbr: abbr.first,
          harmonized_stages: harmonized_stages
        )
      end

      def to_type
        Type.new(
          name: name,
          type_code: type_code,
          abbr: abbr.first
        )
      end

      def abbreviation(format_long: true)
        # If original_abbr is set, check if it should be normalized
        if original_abbr
          # If original is in the abbr array, it's a variant that should normalize
          if abbr.include?(original_abbr)
            # Normalize variants:
            # format_long: true → use long_abbr if available (DAmd), else canonical
            # format_long: false → use canonical (DAM, Amd, Cor)
            if format_long && long_abbr
              return long_abbr
            else
              return abbr.first  # Canonical
            end
          else
            # original_abbr is NOT in abbr array (e.g., "Amd.1" with period+number)
            # Preserve it exactly as parsed
            return original_abbr
          end
        end

        # No original_abbr, use format preference
        if format_long && long_abbr
          long_abbr
        else
          abbr.first  # Default to canonical
        end
      end

      # Returns the canonical (normalized) abbreviation, always abbr.first
      def canonical_abbreviation
        abbr.first
      end

    end
  end
end
