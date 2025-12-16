# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "single_identifier"

module PubidNew
  module Csa
    class Identifier
      def self.parse(input)
        # Filter out comments
        return nil if input.start_with?("#")

        # Filter out non-standards
        return nil if input.match?(/^CSA (Communities|Group|Learning|OnDemand|Update)/)

        # Detect year format before normalization
        # CAN/CSA- standards use dash format: CAN/CSA-C22.2-05
        # Modern CSA standards use colon format: CSA B149:20
        has_dash_year = input.match?(/-\d{2}\b/)

        # Normalize CAN/CSA- to CSA (global replacement for combined identifiers)
        normalized = input.gsub(/CAN\/CSA-/, "CSA ")
        # Normalize CAN3- to CSA (historical prefix)
        normalized = normalized.gsub(/CAN3-/, "CSA ")

        tree = Parser.new.parse(normalized)
        result = Builder.new.build(tree)

        # Set year format if detected as dash and not already set
        if result && has_dash_year && result.year_format.nil?
          result.year_format = "dash"
        end

        result
      rescue Parslet::ParseFailed => e
        raise e
      end
    end
  end
end