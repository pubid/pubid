# frozen_string_literal: true

require "spec_helper"

module IhoFixturesSpec
  FIXTURE_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/iho/identifiers/pass", "*.txt"),
  ).freeze
end

RSpec.describe "IHO Fixture Round-trip Tests" do
  describe "all fixture files" do
    IhoFixturesSpec::FIXTURE_FILES.each do |fixture_file|
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
            parsed = Pubid::Iho.parse(id_str)
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

          if failures.any?
            puts "\n#{File.basename(fixture_file)}: #{successes}/#{identifiers.size}"
            failures.first(5).each do |f|
              if f[:type] == "mismatch"
                puts "    Mismatch: '#{f[:original]}' -> '#{f[:rendered]}'"
              else
                puts "    Error:    '#{f[:original]}': #{f[:error]}"
              end
            end
          end

          expect(failures).to be_empty
        end
      end
    end
  end
end
