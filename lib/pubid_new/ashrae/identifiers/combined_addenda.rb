# frozen_string_literal: true

require "lutaml/model"
require_relative "../supplement_identifier"
require_relative "addendum"
require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Ashrae
    module Identifiers
      # CombinedAddenda identifier for ASHRAE standards and guidelines
      # Represents multiple addendums grouped together
      # Examples:
      # - ASHRAE Addenda c and d to Standard 15-1994
      # - ASHRAE Addenda f and h for Standard 15-2007
      class CombinedAddenda < SupplementIdentifier
        attribute :addendum_codes, :string # Multiple codes like "c and d"
        attribute :connector, :string # "and" or ","

        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Addenda", "Combined Addenda"],
            type_code: "combined_addenda",
            stage_code: "published",
          ),
        ].freeze

        def self.type
          { key: :combined_addenda, title: "ASHRAE Combined Addenda",
            short: "Addenda" }
        end

        def to_s
          return base_identifier.to_s unless base_identifier

          base_type = base_identifier.type || "Standard"
          if addendum_codes
            # Format: ASHRAE Addenda c and d to Standard 15-1994
            result = "ASHRAE Addenda #{addendum_codes} to #{base_type} #{base_identifier.code}"
          else
            # Format: ASHRAE Addenda to Standard 15-1994 (no specific codes)
            result = "ASHRAE Addenda to #{base_type} #{base_identifier.code}"
          end
          result += "-#{base_identifier.year}" if base_identifier.year
          result
        end

        def copublisher
          base_identifier&.copublisher
        end
      end
    end
  end
end
