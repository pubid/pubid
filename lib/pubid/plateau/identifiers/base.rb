# frozen_string_literal: true

module Pubid
  module Plateau
    # Base class for all PLATEAU identifiers. Canonical name
    # Pubid::Plateau::Identifier (Identifiers::Base is a back-compat alias).
    class Identifier < ::Pubid::Identifier
      # Delegate to the flavor module so callers can use
      # `Pubid::Plateau::Identifier.parse` consistently with other flavors.
      def self.parse(identifier)
        Pubid::Plateau.parse(identifier)
      end

      attribute :number, :integer
      attribute :annex, :integer, default: -> {}

      # Stored as a plain string (always "PLATEAU") so it round-trips through
      # to_hash/from_hash. Was a `def publisher` method, which made lutaml
      # serialize a String against the Components::Publisher attribute.
      attribute :publisher, :string, default: -> { "PLATEAU" }

      # Subclasses must implement type_string
      def type_string
        raise NotImplementedError, "Subclasses must implement type_string"
      end

      def formatted_number
        "#%02d" % number
      end

      def formatted_annex
        annex ? "-#{annex}" : ""
      end

      def ==(other)
        return false unless other.class == self.class

        number == other.number &&
          annex == other.annex
      end

      # Include type_string and annex in serialization for round-trip compatibility
      def base_hash
        hash = super
        if self.class.attributes.key?(:type_string) && type_string
          hash[:type] =
            type_string
        end
        hash[:annex] = annex if annex
        hash
      end
    end

    module Identifiers
      # Backward-compatible alias: PLATEAU's base class used to be
      # Pubid::Plateau::Identifiers::Base. It is now Pubid::Plateau::Identifier.
      Base = Pubid::Plateau::Identifier
    end
  end
end
