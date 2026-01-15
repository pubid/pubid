# frozen_string_literal: true

require "lutaml/model"
require_relative "../supplement_identifier"
require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Ashrae
    module Identifiers
      # Addendum identifier for ASHRAE standards and guidelines
      # Examples:
      # - ASHRAE Addendum a to Standard 15-2001
      # - ASHRAE Addendum a to Guideline 1.4-2019
      # - ANSI/ASHRAE Addendum a to ANSI/ASHRAE Standard 15-2019
      # - ASHRAE Standard 15-2013 Addendum a
      class Addendum < SupplementIdentifier
        attribute :addendum_code, :string  # a, b, c, ..., aa, ab, ..., ba, etc.
        attribute :addendum_date, :string  # Optional date (January 22, 2019)

        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Addendum", "Addenda"],
            type_code: "addendum",
            stage_code: "published",
          ),
        ].freeze

        def self.type
          { key: :addendum, title: "ASHRAE Addendum", short: "Addendum" }
        end

        def to_s
          return base_identifier.to_s unless base_identifier

          # Determine base type name for rendering
          base_type = base_identifier.type || "Standard"

          if copublisher
            # Format: ANSI/ASHRAE Addendum a to ANSI/ASHRAE Standard 15-2019
            result = "#{copublisher} Addendum #{addendum_code} to #{base_identifier}"
          else
            # Format: ASHRAE Addendum a to Standard 15-2001
            result = "ASHRAE Addendum #{addendum_code} to #{base_type} #{base_identifier.code}"
            result += "-#{base_identifier.year}" if base_identifier.year
          end

          result += " (#{addendum_date})" if addendum_date
          result
        end

        def copublisher
          base_identifier&.copublisher
        end
      end
    end
  end
end
