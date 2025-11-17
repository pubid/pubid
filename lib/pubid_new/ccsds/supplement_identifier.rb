require "lutaml/model"
require_relative "identifier"

module PubidNew
  module Ccsds
    class SupplementIdentifier < Identifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :number, Components::Code
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage

      # Delegate methods to base_identifier for convenient access
      def publisher
        base_identifier&.publisher
      end

      def series
        base_identifier&.series
      end

      def <=>(other)
        return nil unless other.is_a?(SupplementIdentifier)
        
        # Compare base identifiers first
        base_cmp = base_identifier <=> other.base_identifier
        return base_cmp unless base_cmp.zero?
        
        # Then compare numbers
        num_cmp = (number || Components::Code.new(value: "0")).value.to_i <=> 
                  (other.number || Components::Code.new(value: "0")).value.to_i
        num_cmp
      end
    end
  end
end