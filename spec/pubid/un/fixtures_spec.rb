# frozen_string_literal: true

require "spec_helper"

module UnFixturesSpec
  PASS_FILES = Dir.glob(File.join(__dir__, "../../fixtures/un/pass", "*.txt")).freeze
  FAIL_FILES = Dir.glob(File.join(__dir__, "../../fixtures/un/fail", "*.txt")).freeze
end

RSpec.describe "Pubid::Un Fixture Round-trip Tests" do
  UnFixturesSpec::PASS_FILES.each do |fixture_file|
    describe File.basename(fixture_file) do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "parses and round-trips every identifier" do
        identifiers.each do |id_str|
          parsed = Pubid::Un.parse(id_str)
          expect(parsed).to be_a(Pubid::Un::Identifier)
          # The "UN " prefix is stripped; everything else round-trips.
          expected = id_str.sub(/\AUN /, "")
          expect(parsed.to_s).to eq(expected)
        end
      end
    end
  end

  UnFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "#{File.basename(fixture_file)} (must reject)" do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "rejects every identifier" do
        identifiers.each do |id_str|
          expect { Pubid::Un.parse(id_str) }.to raise_error(/Failed to parse/)
        end
      end
    end
  end
end
