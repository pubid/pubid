# frozen_string_literal: true

require_relative "../supplement_identifier"

module PubidNew
  module Ccsds
    module Identifiers
      class Corrigendum < SupplementIdentifier
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
