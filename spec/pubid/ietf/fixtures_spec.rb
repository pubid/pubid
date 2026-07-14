# frozen_string_literal: true

require "spec_helper"

module IetfFixturesSpec
  FIXTURE_FILES = Dir.glob(File.join(__dir__,
                                     "../../fixtures/ietf/identifiers/pass",
                                     "*.txt")).freeze
end

RSpec.describe "IETF Fixture Round-trip Tests" do
  describe "all fixture files" do
    IetfFixturesSpec::FIXTURE_FILES.each do |fixture_file|
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
            rendered = Pubid::Ietf.parse(id_str).to_s
            if rendered == id_str
              successes += 1
            else
              failures << { original: id_str, rendered: rendered }
            end
          rescue StandardError => e
            failures << { original: id_str, error: "#{e.class}: #{e.message}" }
          end

          total = identifiers.count
          pass_rate =
            total.positive? ? (successes.to_f / total * 100).round(2) : 0

          expect(pass_rate).to be >= 90.0, lambda {
            "Pass rate #{pass_rate}% (#{successes}/#{total}). " \
              "Failures: #{failures.first(10)}"
          }
        end
      end
    end
  end
end
