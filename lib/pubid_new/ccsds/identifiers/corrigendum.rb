# frozen_string_literal: true

require_relative "../supplement_identifier"

module PubidNew
  module Ccsds
    module Identifiers
      class Corrigendum < SupplementIdentifier
        # CCSDS Corrigendum typed stage
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["Cor", "Corr"],
            stage_code: "published",
            type_code: "cor"
          ),
        ].freeze

        # Type information for this identifier class
        #
        # @return [Hash] Type information with key, title, and short form
        def self.type
          { key: :cor, title: "Corrigendum", short: "Cor" }
        end

        attribute :cor_number, :integer

        def to_s
          base_str = base_identifier.to_s
          "#{base_str} Cor. #{cor_number}"
        end

        def ==(other)
          return false unless other.is_a?(Corrigendum)

          base_identifier == other.base_identifier &&
            cor_number == other.cor_number
        end
      end
    end
  end
end
