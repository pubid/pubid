# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS CRPL (Central Radio Propagation Laboratory) Report Identifier
      # Examples:
      # - "NBS CRPL 1-2_3-1" = Reports 1-2 and 3-1 jointly
      # - "NBS CRPL 4-m-5" = Report 4, month m, issue 5
      # - "NBS CRPL c4-4" = Report c4, issue 4
      class CrplReport < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["CRPL", "NBS CRPL", "CRPL-F-B", "CRPL-F-A", "NBS CRPL-F-B",
                   "NBS CRPL-F-A"],
            stage_code: "published",
            type_code: "crpl",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :crpl,
            web: :crpl_report, title: "NBS CRPL Report", short: "CRPL" }
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
          case num_value
          when /^c(\d+.*)$/
            num_value = $1
          # Pattern: 4-m-5 → 4-M-5 (uppercase 'm')
          when /-m-/
            num_value = num_value.gsub("-m-", "-M-")
          # Pattern: m-5 → M-5 (uppercase 'm' at start)
          when /^m-/
            num_value = num_value.gsub(/^m-/, "M-")
          end

          num_value
        end

        # Override number to return normalized value
        # Tests expect number.value to be normalized (c4-4 → 4-4, 4-m-5 → 4-M-5)
        def number
          num = super
          return num unless num

          num_value = num.value.to_s

          # Pattern: c4-4 → 4-4 (hide 'c' prefix)
          case num_value
          when /^c(\d+.*)$/
            num_value = $1
          # Pattern: 4-m-5 → 4-M-5 (uppercase 'm')
          when /-m-/
            num_value = num_value.gsub("-m-", "-M-")
          # Pattern: m-5 → M-5 (uppercase 'm' at start)
          when /^m-/
            num_value = num_value.gsub(/^m-/, "M-")
          end

          # Return new Code object with normalized value
          Components::Code.new(value: num_value)
        end

        def to_s(format = nil)
          # Use actual series attribute if it contains subseries (e.g., "CRPL-F-B")
          # Otherwise use default series_code ("CRPL")
          series_to_render = if series&.value&.include?("CRPL-F-")
                               series.value.sub("NBS ", "") # Remove publisher prefix if present
                             else
                               series_code
                             end

          result = "#{default_publisher} #{series_to_render}"

          if number
            # Normalize number value for CRPL patterns
            num_value = number.value.to_s

            # Pattern: c4-4 → 4-4 (hide 'c' prefix)
            case num_value
            when /^c(\d+.*)$/
              num_value = $1
            # Pattern: 4-m-5 → 4-M-5 (uppercase 'm')
            when /-m-/
              num_value = num_value.gsub("-m-", "-M-")
            # Pattern: m-5 → M-5 (uppercase 'm' at start)
            when /^m-/
              num_value = num_value.gsub(/^m-/, "M-")
            end

            result += " #{prefix}" if prefix
            result += " #{num_value}"
          end

          # Append the shared component tail (part, supplement, edition,
          # index, section, ...) so distinct CRPL reports do not collide.
          # range_notation is CRPL-specific and always trails the identifier.
          result += append_short_components

          result += range_notation if range_notation
          result
        end
      end
    end
  end
end
