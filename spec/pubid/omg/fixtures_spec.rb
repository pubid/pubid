# frozen_string_literal: true

require "spec_helper"

module OmgFixturesSpec
  PASS_FILES = Dir.glob(File.join(__dir__, "../../fixtures/omg/pass", "*.txt")).freeze
  FAIL_FILES = Dir.glob(File.join(__dir__, "../../fixtures/omg/fail", "*.txt")).freeze
end

RSpec.describe "Pubid::Omg Fixture Round-trip Tests" do
  OmgFixturesSpec::PASS_FILES.each do |fixture_file|
    describe File.basename(fixture_file) do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "parses and round-trips every identifier" do
        identifiers.each do |id_str|
          parsed = Pubid::Omg.parse(id_str)
          expect(parsed).to be_a(Pubid::Omg::Identifier)
          expect(parsed.to_s).to eq(id_str)
        end
      end
    end
  end

  OmgFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "#{File.basename(fixture_file)} (must reject)" do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "rejects every identifier" do
        identifiers.each do |id_str|
          expect { Pubid::Omg.parse(id_str) }.to raise_error(/Failed to parse/)
        end
      end
    end
  end
end
