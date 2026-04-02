# frozen_string_literal: true

require_relative "supplement_identifier"

module PubidNew
  module Ieee
    module Identifiers
      # Conformance identifier for IEEE standards
      # Represents conformance test documents
      # Example: IEEE Std 802.16/Conformance01-2003
      class ConformanceIdentifier < SupplementIdentifier
        attribute :conf_number, :string
        attribute :conf_year, :string

        # TYPED_STAGES for conformance
        # Conformance uses "Conformance" abbreviation
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Conformance"],
            type_code: "conformance",
            stage_code: "published",
          ),
        ].freeze

        def to_s
          return base_identifier.to_s unless base_identifier

          # Format: BASE/ConformanceNN-YEAR
          result = base_identifier.to_s
          result += "/Conformance#{conf_number}" if conf_number
          result += "-#{conf_year}" if conf_year
          result
        end
      end
    end
  end
end
