# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # TestMethod represents BSI test method identifiers
      # Format: BS {number}:{test_series}:{test_id}:{year}
      #
      # Examples:
      #   BS 1006:B01C:LFS1:1982
      #   BS 1006:B01C:LFS2:1985
      #   BS 1006:B01C:LFS4:1990
      class TestMethod < SingleIdentifier
        attribute :test_series, :string     # Test series code (e.g., "B01C")
        attribute :test_id, :string         # Test ID (e.g., "LFS1")

        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubtestmethod,
            stage_code: :published,
            type_code: :test_method,
            abbr: ["BS"],
            name: "Test Method",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :test_method, title: "Test Method", short: "BS" }
        end

        def to_s(lang: :en, lang_single: false)
          # Test Method format: BS {number}:{test_series}:{test_id}:{year}
          parts = []

          # Publisher (BS)
          parts << "BS"

          # Number
          if number
            number_str = if number.respond_to?(:value)
                           number.value.to_s
                         else
                           number.to_s
                         end
            parts << number_str
          end

          result = parts.join(" ")

          # Test series and test ID suffixes
          if test_series && test_id
            result += ":#{test_series}:#{test_id}"
          end

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
            result += ":#{year_val}"
          end

          result
        end
      end
    end
  end
end
