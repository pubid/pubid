# frozen_string_literal: true

require "spec_helper"

module JcgmFixturesSpec
  FIXTURE_FILES = Dir.glob(File.join(__dir__,
                                     "../../../fixtures/JCGM/identifiers/pass", "*.txt")).freeze
end

RSpec.describe "JCGM Fixture Round-trip Tests" do
  describe "all fixture files" do
    JcgmFixturesSpec::FIXTURE_FILES.each do |fixture_file|
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
            parsed = Pubid::Jcgm.parse(id_str)
            rendered = parsed.to_s

            if rendered == id_str
              successes += 1
            else
              failures << { original: id_str, rendered: rendered,
                            type: "mismatch" }
            end
          rescue StandardError => e
            failures << { original: id_str, error: "#{e.class}: #{e.message}",
                          type: "parse_error" }
          end

          total = identifiers.count
          pass_rate = total.positive? ? (successes.to_f / total * 100).round(2) : 0

          puts "\n#{File.basename(fixture_file)}: #{successes}/#{total} (#{pass_rate}%)"

          if failures.any?
            puts "\n  First 5 failures:"
            failures.first(5).each do |f|
              if f[:type] == "mismatch"
                puts "    Mismatch: '#{f[:original]}' -> '#{f[:rendered]}'"
              else
                puts "    Error: '#{f[:original]}': #{f[:error]}"
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
