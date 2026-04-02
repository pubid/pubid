# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Plateau
    # Base class for PLATEAU supplements (Annex)
    # Supplements reference a base identifier
    class SupplementIdentifier < Lutaml::Model::Serializable
      include Pubid::Serializable

      attribute :base_identifier, Identifiers::Base
      attribute :letter, :string, default: -> {}

      def publisher
        "PLATEAU"
      end

      # Subclasses must implement supplement_string
      def supplement_string
        raise NotImplementedError, "Subclasses must implement supplement_string"
      end

      def to_s
        "#{base_identifier} #{supplement_string}"
      end

      # Override base_hash to extract edition, type, and annex from base_identifier
      def base_hash
        hash = super
        # For Plateau supplements, edition comes from the base identifier
        if base_identifier.respond_to?(:edition) && base_identifier.edition
          hash[:edition] = base_identifier.edition
        end
        # Include type from base_identifier
        if base_identifier.respond_to?(:type_string) && base_identifier.type_string
          hash[:type] = base_identifier.type_string
        end
        # Include annex from base_identifier
        if base_identifier.respond_to?(:annex) && base_identifier.annex
          hash[:annex] = base_identifier.annex
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

        base_identifier == other.base_identifier &&
          letter == other.letter
      end
    end
  end
end
