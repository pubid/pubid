# frozen_string_literal: true

require_relative "../supplement_identifier"

module PubidNew
  module Ccsds
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attr_accessor :cor_number

        def initialize(base_identifier: nil, cor_number: nil)
          super(base_identifier: base_identifier)
          @cor_number = cor_number
        end

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