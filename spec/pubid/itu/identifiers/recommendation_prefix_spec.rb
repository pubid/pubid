# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ITU 'Recommendation' long-form prefix — issue #233" do
  describe "accepts the verbose prefix and normalizes it away" do
    {
      "Recommendation ITU-T H.265 (2021)" => "ITU-T H.265 (2021)",
      "Recommendation ITU-T H.222.0 (2021)" => "ITU-T H.222.0 (2021)",
      "Recommendation ITU-R BO.600-1" => "ITU-R BO.600-1",
    }.each do |input, expected|
      it "parses #{input.inspect} -> #{expected.inspect}" do
        parsed = Pubid::Itu.parse(input)
        expect(parsed.to_s).to eq(expected)
      end
    end
  end

  describe "bare form (no prefix) still works" do
    it "parses ITU-T H.265 (2021) unchanged" do
      parsed = Pubid::Itu.parse("ITU-T H.265 (2021)")
      expect(parsed.to_s).to eq("ITU-T H.265 (2021)")
    end
  end

  describe "twin-text reference" do
    it "parses the ITU side of an H.265 twin-text reference" do
      # Full twin-text form "... | ISO/IEC ..." is tracked separately in #234;
      # this just verifies the ITU half parses once the prefix is stripped.
      parsed = Pubid::Itu.parse("Recommendation ITU-T H.265 (2021)")
      expect(parsed.series.series).to eq("H")
      expect(parsed.code.number).to eq("265")
      expect(parsed.date.year).to eq("2021")
    end
  end
end
