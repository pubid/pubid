# frozen_string_literal: true

require "spec_helper"

module DoiFixturesSpec
  PASS_FILES = Dir.glob(File.join(__dir__, "../../fixtures/doi/pass", "*.txt")).freeze
  FAIL_FILES = Dir.glob(File.join(__dir__, "../../fixtures/doi/fail", "*.txt")).freeze
end

RSpec.describe "Pubid::Doi Fixture Round-trip Tests" do
  DoiFixturesSpec::PASS_FILES.each do |fixture_file|
    describe File.basename(fixture_file) do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "parses every identifier" do
        identifiers.each do |id_str|
          parsed = Pubid::Doi.parse(id_str)
          expect(parsed).to be_a(Pubid::Doi::Identifier)
          expect(parsed.to_s).to match(%r{\Adoi:10\.\d+/.+\z})
        end
      end
    end
  end

  DoiFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "#{File.basename(fixture_file)} (must reject)" do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "rejects every identifier" do
        identifiers.each do |id_str|
          expect { Pubid::Doi.parse(id_str) }.to raise_error(/Failed to parse/)
        end
      end
    end
  end
end
