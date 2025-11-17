require "lutaml/model"
require_relative "identifier"

module PubidNew
  module Cen
    class SupplementIdentifier < Identifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :number, Components::Code
      attribute :date, Components::Date
      attribute :stage, Components::Stage
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage

      # Delegate methods to base_identifier for convenient access
      def publisher
        base_identifier&.publisher
      end

      def copublishers
        base_identifier&.copublishers
      end

      def <=>(other)
        return nil unless other.is_a?(SupplementIdentifier)
        
        # Compare base identifiers first
        base_cmp = base_identifier <=> other.base_identifier
        return base_cmp unless base_cmp.zero?
        
        # Then compare numbers
        num_cmp = (number || Components::Code.new(value: "0")).to_s <=> (other.number || Components::Code.new(value: "0")).to_s
        return num_cmp unless num_cmp.zero?
        
        # Finally compare dates
        if date && other.date
          date.to_s <=> other.date.to_s
        elsif date
          1
        elsif other.date
          -1
        else
          0
        end
      end
    end
  end
end