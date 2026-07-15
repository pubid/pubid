# frozen_string_literal: true

require "spec_helper"

module EcmaFixturesSpec
  FIXTURE_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/ecma/identifiers/pass", "*.txt"),
  ).freeze
end

RSpec.describe "ECMA Fixture Round-trip Tests" do
  describe "all fixture files" do
    EcmaFixturesSpec::FIXTURE_FILES.each do |fixture_file|
      describe File.basename(fixture_file) do
        let(:identifiers) do
          File.readlines(fixture_file).map(&:strip).reject do |line|
            line.empty? || line.start_with?("#")
          end
        end

        it "parses and round-trips identifiers" do
          failures = []

          identifiers.each do |id_str|
            rendered = Pubid::Ecma.parse(id_str).to_s
            unless rendered == id_str
              failures << { original: id_str, rendered: rendered,
                            type: "mismatch" }
            end
          rescue StandardError => e
            failures << { original: id_str, error: "#{e.class}: #{e.message}",
                          type: "parse_error" }
          end

          expect(failures).to be_empty
        end
      end
    end
  end
end
