# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ISO V2 Comprehensive Fixtures Tests" do
  FIXTURE_FILES = [
    "iso-pubid-basic.txt",
    "iso-pubid-cd.txt",
    "iso-pubid-coramd.txt",
    "iso-pubid-directives.txt",
    "iso-pubid-draft-amd-cor.txt",
    "iso-pubid-french.txt",
    "iso-pubid-languages.txt",
    "iso-pubid-legacy-tr-ts.txt",
    "iso-pubid-supplement-iteration.txt",
    "iwa-pubid.txt",
  ].freeze

  FIXTURE_FILES.each do |fixture_file|
    describe fixture_file do
      let(:fixture_path) do
        File.join(__dir__,
                  "../../../archived-gems/pubid-iso/spec/fixtures/#{fixture_file}")
      end
      let(:fixture_ids) do
        File.readlines(fixture_path).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "parses and round-trips #{fixture_file} identifiers" do
        successes = 0
        failures = []

        fixture_ids.each do |id_str|
          parsed = Pubid::Iso.parse(id_str)
          if parsed.to_s == id_str
            successes += 1
          else
            failures << { original: id_str, rendered: parsed.to_s,
                          type: "mismatch" }
          end
        rescue StandardError => e
          failures << { original: id_str, error: e.class.name,
                        type: "parse_error" }
        end

        total = fixture_ids.count
        pass_rate = (successes.to_f / total * 100).round(2)

        if failures.any?

          failures.first(10).each do |f|
            if f[:type] == "mismatch"

            end
          end

          if failures.count > 10

          end
        end

        # Expect at least 95% pass rate
        expect(pass_rate).to be >= 95.0, "Expected ≥95% but got #{pass_rate}%"
      end
    end
  end

  describe "Combined results" do
    it "reports overall success rate across all files" do
      total_successes = 0
      total_identifiers = 0

      FIXTURE_FILES.each do |fixture_file|
        fixture_path = File.join(__dir__,
                                 "../../../archived-gems/pubid-iso/spec/fixtures/#{fixture_file}")
        fixture_ids = File.readlines(fixture_path).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end

        fixture_ids.each do |id_str|
          total_identifiers += 1
          begin
            parsed = Pubid::Iso.parse(id_str)
            total_successes += 1 if parsed.to_s == id_str
          rescue StandardError
            # Count as failure
          end
        end
      end

      overall_pass_rate = (total_successes.to_f / total_identifiers * 100).round(2)

      expect(overall_pass_rate).to be >= 95.0,
                                   "Expected ≥95% overall but got #{overall_pass_rate}%"
    end
  end
end
