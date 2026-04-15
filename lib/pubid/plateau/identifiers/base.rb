# frozen_string_literal: true

module Pubid
  module Plateau
    module Identifiers
      # Base class for all PLATEAU identifiers
      class Base < Lutaml::Model::Serializable
        include Pubid::Serializable

        # Generate URN for this identifier
        #
        # @return [String] URN representation
        def to_urn
          UrnGenerator.new(self).generate
        end
        attribute :number, :integer
        attribute :annex, :integer, default: -> {}

        def publisher
          "PLATEAU"
        end

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
          hash[:type] = type_string if respond_to?(:type_string)
          hash[:annex] = annex if annex
          hash
        end
      end
    end
  end
end
