# frozen_string_literal: true

require "spec_helper"

module EvsFixturesSpec
  FIXTURE_FILES = Dir.glob(
    File.join(__dir__, "../../../fixtures/evs/identifiers/pass", "*.txt")
  ).freeze
end

RSpec.describe "EVS Fixture Round-trip Tests" do
  describe "all fixture files" do
    EvsFixturesSpec::FIXTURE_FILES.each do |fixture_file|
      describe File.basename(fixture_file) do
        let(:identifiers) do
          File.readlines(fixture_file).map(&:strip).reject do |line|
            line.empty? || line.start_with?("#")
          end
        end

        it "parses and round-trips every identifier exactly" do
          failures = identifiers.filter_map do |id_str|
            rendered = Pubid::Evs.parse(id_str).to_s
            next if rendered == id_str

            { original: id_str, rendered: rendered }
          rescue StandardError => e
            { original: id_str, error: "#{e.class}: #{e.message}" }
          end

          # All EVS fixtures are canonical printed forms - exact round trip.
          expect(failures).to be_empty,
                              "round-trip failures: #{failures.inspect}"
        end

        it "round-trips every identifier through its URN" do
          failures = identifiers.filter_map do |id_str|
            urn = Pubid::Evs.parse(id_str).to_urn
            back = Pubid.parse(urn, format: :urn).to_s
            next if back == id_str

            { original: id_str, urn: urn, back: back }
          rescue StandardError => e
            { original: id_str, error: "#{e.class}: #{e.message}" }
          end

          expect(failures).to be_empty,
                              "URN round-trip failures: #{failures.inspect}"
        end
      end
    end
  end
end
