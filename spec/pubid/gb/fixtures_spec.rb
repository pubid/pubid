# frozen_string_literal: true

require "spec_helper"

module GbFixturesSpec
  PASS_FILES = Dir.glob(File.join(__dir__, "../../fixtures/gb/pass", 
                                  "*.txt")).freeze
  FAIL_FILES = Dir.glob(File.join(__dir__, "../../fixtures/gb/fail", 
                                  "*.txt")).freeze
end

RSpec.describe "Pubid::Gb Fixture Round-trip Tests" do
  GbFixturesSpec::PASS_FILES.each do |fixture_file|
    describe File.basename(fixture_file) do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "parses and round-trips every identifier in the file" do
        identifiers.each do |id_str|
          parsed = Pubid::Gb.parse(id_str)
          expect(parsed).to be_a(Pubid::Gb::Identifier)
          expect(parsed.to_s).to eq(id_str)
        end
      end
    end
  end

  GbFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "#{File.basename(fixture_file)} (must reject)" do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "rejects every identifier in the file" do
        identifiers.each do |id_str|
          expect { Pubid::Gb.parse(id_str) }.to raise_error(/Failed to parse/)
        end
      end
    end
  end
end
