# frozen_string_literal: true

require_relative "supplement_identifier"

module PubidNew
  module Ieee
    module Identifiers
      # Corrigendum identifier for IEEE standards
      # Represents corrections to published standards
      # Example: IEEE Std 535-2013/Cor. 1-2017
      class Corrigendum < SupplementIdentifier
        attribute :cor_number, :string
        attribute :cor_year, :string

        # TYPED_STAGES for corrigendum
        # Corrigendum uses "Cor" abbreviation
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Cor"],
            type_code: "corrigendum",
            stage_code: "published",
          ),
        ].freeze

        def to_s
          return super unless base_identifier

          # Format: BASE/Cor NUMBER-YEAR or BASE/Cor. NUMBER-YEAR
          result = base_identifier.to_s
          result += "/Cor"
          result += ". " if cor_number # Add period and space for formal format
          result += cor_number if cor_number
          result += "-#{cor_year}" if cor_year
          result
        end
      end
    end
  end
end
