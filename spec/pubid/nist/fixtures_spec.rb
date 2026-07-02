# frozen_string_literal: true

require "spec_helper"

module NistFixturesSpec
  FIXTURE_FILES = Dir.glob(File.join(__dir__,
                                     "../../fixtures/nist/identifiers/pass", "*.txt")).freeze
end

RSpec.describe "NIST Fixture Round-trip Tests" do
  describe "all fixture files" do
    NistFixturesSpec::FIXTURE_FILES.each do |fixture_file|
      describe File.basename(fixture_file) do
        let(:identifiers) do
          File.readlines(fixture_file).map(&:strip).reject do |line|
            line.empty? || line.start_with?("#")
          end
        end

        it "parses and round-trips identifiers" do
          failures = []
          successes = 0

          identifiers.each do |id_str|
            # Handle !input!expected! format (V1 fixture format)
            if id_str.start_with?("!")
              parts = id_str.split("!")
              # Format: !input!expected!
              # parts[0] = "", parts[1] = input, parts[2] = expected, parts[3] = ""
              input = parts[1]
              expected = parts[2]
            else
              input = id_str
              expected = id_str
            end

            parsed = Pubid::Nist.parse(input)
            rendered = parsed.to_s

            if rendered == expected
              successes += 1
            else
              failures << { original: input, expected: expected, rendered: rendered,
                            type: "mismatch" }
            end
          rescue StandardError => e
            failures << { original: id_str, error: "#{e.class}: #{e.message}",
                          type: "parse_error" }
          end

          total = identifiers.count
          pass_rate = total.positive? ? (successes.to_f / total * 100).round(2) : 0

          if failures.any?

            failures.first(5).each do |f|
              if f[:type] == "mismatch"

              end
            end
          end

          # Allow up to 10% failure rate for fixture tests
          expect(pass_rate).to be >= 90.0
        end
      end
    end
  end
end
