# frozen_string_literal: true

require_relative "identifiers/base"

module PubidNew
  module Ccsds
    # Base class for CCSDS supplements (corrigenda, amendments, etc.)
    # Following ISO pattern: inherits from Base and uses Lutaml::Model
    class SupplementIdentifier < Identifiers::Base
      attribute :base_identifier, Identifiers::Base, polymorphic: true

      # Delegate methods to base_identifier for convenient access
      def publisher
        base_identifier&.publisher
      end

      def number
        base_identifier&.number
      end

      def <=>(other)
        return nil unless other.is_a?(SupplementIdentifier)

        # Compare base identifiers first
        if base_identifier && other.base_identifier
          base_cmp = base_identifier <=> other.base_identifier
          return base_cmp unless base_cmp.zero?
        end

        # Subclasses should implement more specific comparison
        0
      end
    end
  end
end
