# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    # WrapperIdentifier is the base class for all CSA identifiers that wrap other identifiers
    # Examples:
    #   - CanadianAdoptedIdentifier: CAN/{wrapped_identifier}
    #   - CsaAdoptedIdentifier: CSA {ISO/IEC/CISPR identifier}
    #
    # The wrapper pattern allows proper MODEL-DRIVEN architecture where adoptions
    # are objects that contain other identifier objects, not string prefixes.
    class WrapperIdentifier < Lutaml::Model::Serializable
      # The wrapped identifier (recursively parsed)
      # Don't specify type - can be any CSA identifier object
      attribute :wrapped_identifier, :string  # Actually holds object, but no type constraint

      # Reaffirmation year (common across wrappers)
      attribute :reaffirmation, :string

      # Year format tracking (for compatibility)
      attribute :year_format, :string

      # Subclasses MUST implement to_s
      def to_s
        raise NotImplementedError, "Subclasses must implement to_s method"
      end
    end
  end
end