# frozen_string_literal: true

require "spec_helper"

module IsbnFixturesSpec
  PASS_FILES = Dir.glob(File.join(__dir__, "../../fixtures/isbn/pass", "*.txt")).freeze
  FAIL_FILES = Dir.glob(File.join(__dir__, "../../fixtures/isbn/fail", "*.txt")).freeze
end

RSpec.describe "Pubid::Isbn Fixture Round-trip Tests" do
  IsbnFixturesSpec::PASS_FILES.each do |fixture_file|
    describe File.basename(fixture_file) do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "parses every identifier" do
        identifiers.each do |id_str|
          parsed = Pubid::Isbn.parse(id_str)
          expect(parsed).to be_a(Pubid::Isbn::Identifier)
          expect(parsed).to be_valid
        end
      end
    end
  end

  IsbnFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "#{File.basename(fixture_file)} (must reject)" do
      let(:identifiers) do
        File.readlines(fixture_file).map(&:strip).reject do |line|
          line.empty? || line.start_with?("#")
        end
      end

      it "rejects every identifier" do
        identifiers.each do |id_str|
          expect { Pubid::Isbn.parse(id_str) }.to raise_error(/Failed to parse|check digit|length/)
        end
      end
    end
  end
end
