# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/pubid/itu"

# OB (Operational Bulletin) is a cross-bureau ITU publication and must not
# have a sector. Legacy strings like "ITU-T OB.1096" still parse successfully
# — the bureau is dropped during normalization.
RSpec.describe Pubid::Itu::Identifiers::SpecialPublication do
  describe "round-trip parsing and rendering" do
    shared_examples "parses and normalizes" do |input, expected|
      it "parses #{input.inspect} as #{expected.inspect}" do
        identifier = Pubid::Itu.parse(input)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq(expected)
        expect(identifier.sector).to be_nil
      end
    end

    it_behaves_like "parses and normalizes",
                    "ITU OB No. 1283", "ITU OB No. 1283"
    it_behaves_like "parses and normalizes",
                    "ITU-T OB.1096", "ITU OB No. 1096"
    it_behaves_like "parses and normalizes",
                    "ITU-T OB No. 1096", "ITU OB No. 1096"
    it_behaves_like "parses and normalizes",
                    "ITU-T Operational Bulletin No. 1096", "ITU OB No. 1096"

    it "preserves date" do
      identifier = Pubid::Itu.parse("ITU OB No. 1283 (01/2024)")
      expect(identifier.to_s).to eq("ITU OB No. 1283 (01/2024)")
    end

    it "preserves language suffix" do
      identifier = Pubid::Itu.parse("ITU OB No. 1000-F")
      expect(identifier.to_s).to eq("ITU OB No. 1000-F")
      expect(identifier.language).to eq("F")
    end
  end

  describe "OB-no-sector validation" do
    it "raises when constructed with sector" do
      expect do
        described_class.new(
          sector: Pubid::Itu::Components::Sector.new(sector: "T"),
          series: Pubid::Itu::Components::Series.new(series: "OB"),
          code: Pubid::Itu::Components::Code.new(number: "1"),
        )
      end.to raise_error(ArgumentError, /cross-bureau/)
    end

    it "does not raise when sector is nil" do
      expect do
        described_class.new(
          series: Pubid::Itu::Components::Series.new(series: "OB"),
          code: Pubid::Itu::Components::Code.new(number: "1"),
        )
      end.not_to raise_error
    end
  end

  describe "direct construction" do
    def ob(number:, language: nil)
      described_class.new(
        series: Pubid::Itu::Components::Series.new(series: "OB"),
        code: Pubid::Itu::Components::Code.new(number: number.to_s),
        language: language&.to_s,
      )
    end

    it "builds SpecialPublication via .new" do
      identifier = ob(number: 1000)
      expect(identifier).to be_a(described_class)
      expect(identifier.to_s).to eq("ITU OB No. 1000")
    end

    it "normalizes long-form language to single-letter" do
      identifier = ob(number: 1000, language: :fr)
      expect(identifier.language).to eq("F")
      expect(identifier.to_s).to eq("ITU OB No. 1000-F")
    end
  end
end
