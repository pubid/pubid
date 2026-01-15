# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      # NBS CRPL (Central Radio Propagation Laboratory) Report Identifier
      # Examples:
      # - "NBS CRPL 1-2_3-1" = Reports 1-2 and 3-1 jointly
      # - "NBS CRPL 4-m-5" = Report 4, month m, issue 5
      # - "NBS CRPL c4-4" = Report c4, issue 4
      class CrplReport < Base
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["CRPL", "NBS CRPL"],
            stage_code: "published",
            type_code: "crpl"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :crpl, title: "NBS CRPL Report", short: "CRPL" }
          end
        end

        attribute :range_notation, :string # For underscore ranges like "1-2_3-1"
        attribute :prefix, :string # For "c" or "m" prefixes

        def default_publisher
          "NBS"
        end

        def series_code
          "CRPL"
        end

        # Return normalized number value for tests
        # - c4-4 → 4-4 (remove 'c' prefix)
        # - 4-m-5 → 4-M-5 (uppercase 'm')
        def normalized_number
          return nil unless number

          num_value = number.value.to_s

          # Pattern: c4-4 → 4-4 (hide 'c' prefix)
          if num_value =~ /^c(\d+.*)$/
            num_value = $1
          # Pattern: 4-m-5 → 4-M-5 (uppercase 'm')
          elsif num_value =~ /-m-/
            num_value = num_value.gsub(/-m-/, '-M-')
          # Pattern: m-5 → M-5 (uppercase 'm' at start)
          elsif num_value =~ /^m-/
            num_value = num_value.gsub(/^m-/, 'M-')
          end

          num_value
        end

        # Override number to return normalized value
        # Tests expect number.value to be normalized (c4-4 → 4-4, 4-m-5 → 4-M-5)
        def number
          num = super()
          return num unless num

          num_value = num.value.to_s

          # Pattern: c4-4 → 4-4 (hide 'c' prefix)
          if num_value =~ /^c(\d+.*)$/
            num_value = $1
          # Pattern: 4-m-5 → 4-M-5 (uppercase 'm')
          elsif num_value =~ /-m-/
            num_value = num_value.gsub(/-m-/, '-M-')
          # Pattern: m-5 → M-5 (uppercase 'm' at start)
          elsif num_value =~ /^m-/
            num_value = num_value.gsub(/^m-/, 'M-')
          end

          # Return new Code object with normalized value
          Components::Code.new(number: num_value)
        end

        def to_s
          result = "#{default_publisher} #{series_code}"

          if number
            # Normalize number value for CRPL patterns
            num_value = number.value.to_s

            # Pattern: c4-4 → 4-4 (hide 'c' prefix)
            if num_value =~ /^c(\d+.*)$/
              num_value = $1
            # Pattern: 4-m-5 → 4-M-5 (uppercase 'm')
            elsif num_value =~ /-m-/
              num_value = num_value.gsub(/-m-/, '-M-')
            # Pattern: m-5 → M-5 (uppercase 'm' at start)
            elsif num_value =~ /^m-/
              num_value = num_value.gsub(/^m-/, 'M-')
            end

            result += " #{prefix}" if prefix
            result += " #{num_value}"
          end

          # Add part component (pt3-1)
          result += part.to_s if part

          # Add supplement with "sup" prefix for CRPL identifiers
          if supplement
            # Check if supplement already has "sup" prefix (for backward compatibility)
            result += (supplement.start_with?('sup') ? supplement : "sup#{supplement}")
          end

          result += range_notation if range_notation
          result
        end
      end
    end
  end
end
