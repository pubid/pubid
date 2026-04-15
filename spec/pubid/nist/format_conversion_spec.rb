# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Format Cross-Conversion" do
  describe "Stage identifiers" do
    let(:examples) do
      [
        "NIST SP 800-53r5 ipd",      # short with inline stage
        "NIST.SP.800-53r5.ipd",      # mr format
        "NIST SP(IPD) 800-53r5", # old style parenthetical
      ]
    end

    it "parses all formats to same components" do
      parsed_identifiers = examples.map { |input| Pubid::Nist.parse(input) }

      # All should have same stage
      parsed_identifiers.each do |id|
        expect(id.stage).not_to be_nil
        expect(id.stage.id).to eq("i")
        expect(id.stage.type).to eq("pd")

        # All should have same number and revision
        expect(id.number.value).to eq("800-53")
        expect(id.revision).to eq("r5")
      end
    end

    it "converts between all formats correctly" do
      examples.each do |input|
        parsed = Pubid::Nist.parse(input)

        # Generate all 4 formats
        short = parsed.to_s(:short)
        mr = parsed.to_s(:mr)
        long = parsed.to_s(:long)
        abbrev = parsed.to_s(:abbrev)

        # Check format characteristics
        expect(short).to eq("NIST SP 800-53r5 ipd")
        expect(mr).to eq("NIST.SP.800-53r5.ipd")
        expect(long).to include("National Institute")
        expect(abbrev).to include("Natl. Inst.")

        # Re-parse rendered formats
        reparsed_short = Pubid::Nist.parse(short)
        reparsed_mr = Pubid::Nist.parse(mr)

        # Should have same components
        expect(reparsed_short.stage.id).to eq("i")
        expect(reparsed_mr.stage.id).to eq("i")
        expect(reparsed_short.number.value).to eq("800-53")
        expect(reparsed_mr.number.value).to eq("800-53")
      end
    end
  end

  describe "Translation identifiers" do
    let(:examples) do
      [
        "NIST SP 1262 spa",          # short with space
        "NIST.SP.1262.spa",          # mr format
        "NIST SP 1262(spa)",         # parenthetical
        "NIST SP 1262es", # Transform es → spa
      ]
    end

    it "parses all formats to normalized translation" do
      parsed_identifiers = examples.map { |input| Pubid::Nist.parse(input) }

      # All should normalize to 'spa'
      parsed_identifiers.each do |id|
        expect(id.translation_component).not_to be_nil
        expect(id.translation_component.code).to eq("spa")
      end
    end

    it "converts between formats with consistency" do
      examples.each do |input|
        parsed = Pubid::Nist.parse(input)

        short = parsed.to_s(:short)
        mr = parsed.to_s(:mr)

        # Check normalized output (all should render as "spa")
        expect(short).to eq("NIST SP 1262 spa")
        expect(mr).to eq("NIST.SP.1262.spa")

        # Re-parse and verify
        reparsed = Pubid::Nist.parse(short)
        expect(reparsed.translation_component.code).to eq("spa")
      end
    end
  end

  describe "Combined stage + translation" do
    it "handles both stage and translation correctly" do
      input = "NIST SP 800-189 ipd spa"
      parsed = Pubid::Nist.parse(input)

      # Should have both components
      expect(parsed.stage.id).to eq("i")
      expect(parsed.translation_component.code).to eq("spa")

      # Should render both in all formats
      short = parsed.to_s(:short)
      mr = parsed.to_s(:mr)

      expect(short).to include("ipd")
      expect(short).to include("spa")
      expect(mr).to include(".ipd")
      expect(mr).to include(".spa")
    end
  end

  describe "Round-trip fidelity" do
    let(:test_cases) do
      [
        "NIST SP 800-53r5",
        "NIST SP 800-53r5 ipd",
        "NIST SP 1262 spa",
        "NIST SP 800-189 ipd spa",
        "NIST.SP.800-53r5.ipd",
        "NIST.SP.1262.spa",
      ]
    end

    it "preserves format on round-trip" do
      test_cases.each do |input|
        parsed = Pubid::Nist.parse(input)

        # Determine original format
        format = input.include?(".") ? :mr : :short

        # Render in original format
        output = parsed.to_s(format)

        # Re-parse
        reparsed = Pubid::Nist.parse(output)

        # Should render identically
        expect(reparsed.to_s(format)).to eq(output)
      end
    end
  end
end
