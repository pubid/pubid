# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Plateau
    # Base class for PLATEAU supplements (Annex)
    # Supplements reference a base identifier
    class SupplementIdentifier < Pubid::Identifier
      attribute :base, Identifiers::Base
      attribute :letter, :string, default: -> {}

      def publisher
        "PLATEAU"
      end

      # Subclasses must implement supplement_string
      def supplement_string
        raise NotImplementedError, "Subclasses must implement supplement_string"
      end

      # Override base_hash to extract edition, type, and annex from base
      def base_hash
        hash = super
        # For Plateau supplements, edition comes from the base identifier
        if base.class.attributes.key?(:edition) && base.edition
          hash[:edition] = base.edition
        end
        # Include type from base
        if base.class.attributes.key?(:type_string) && base.type_string
          hash[:type] = base.type_string
        end
        # Include annex from base
        if base.class.attributes.key?(:annex) && base.annex
          hash[:annex] = base.annex
        end
        hash
      end

      # Override supplement_hash to include letter instead of number
      def supplement_hash(supplement)
        {
          type: extract_supplement_type(supplement),
          letter: supplement.letter,
        }.compact
      end

      # Extract supplement type from class name
      def extract_supplement_type(supplement)
        return nil unless supplement.class

        # Get class name without namespace
        class_name = supplement.class.name.to_s
        parts = class_name.split("::")
        simple_name = parts.last
        # Convert camel case to snake case (Annex -> annex)
        simple_name&.gsub(/([a-z])([A-Z])/, '\1_\2')&.downcase
      end

      def ==(other)
        return false unless other.class == self.class

        base == other.base &&
          letter == other.letter
      end
    end
  end
end
