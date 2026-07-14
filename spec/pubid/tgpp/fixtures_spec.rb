# frozen_string_literal: true

require "spec_helper"

module TgppFixturesSpec
  FIXTURE_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/tgpp/identifiers/pass", "*.txt"),
  ).freeze
end

RSpec.describe "3GPP Fixture Round-trip Tests" do
  describe "all fixture files" do
    TgppFixturesSpec::FIXTURE_FILES.each do |fixture_file|
      describe File.basename(fixture_file) do
        let(:identifiers) do
          File.readlines(fixture_file).map(&:strip).reject do |line|
            line.empty? || line.start_with?("#")
          end
        end

        it "parses and round-trips every identifier" do
          failures = []

          identifiers.each do |id_str|
            rendered = Pubid::Tgpp.parse(id_str).to_s
            if rendered != id_str
              failures << { original: id_str, rendered: rendered }
            end
          rescue StandardError => e
            failures << { original: id_str, error: "#{e.class}: #{e.message}" }
          end

          expect(failures).to be_empty,
                              -> { failures.first(5).map(&:inspect).join("\n") }
        end
      end
    end
  end
end
