# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Revision Format Preservation" do
  describe "preserves original revision format" do
    # Per design document, revision formatting should be preserved
    # "Rev. 5" should NOT be rendered as "r5"

    it "preserves Rev. format (capital R with period and space)" do
      identifier = Pubid::Nist.parse("NIST SP 800-53 Rev. 5")
      expect(identifier.to_s).to eq("NIST SP 800-53 Rev. 5")
    end

    it "preserves r format (lowercase r)" do
      identifier = Pubid::Nist.parse("NIST SP 800-53 r5")
      expect(identifier.to_s).to eq("NIST SP 800-53 r5")
    end
  end

  describe "round-trip fidelity for preserved formats" do
    it "maintains Rev. format through parse-serialize-parse cycle" do
      original = "NIST SP 800-53 Rev. 5"
      first = Pubid::Nist.parse(original)
      serialized = first.to_s
      second = Pubid::Nist.parse(serialized)

      expect(serialized).to eq(original)
      expect(second.to_s).to eq(original)
    end

    it "maintains r format through parse-serialize-parse cycle" do
      original = "NIST SP 800-53 r5"
      first = Pubid::Nist.parse(original)
      serialized = first.to_s
      second = Pubid::Nist.parse(serialized)

      expect(serialized).to eq(original)
      expect(second.to_s).to eq(original)
    end
  end

  describe "revision with letters" do
    it "preserves Rev. format with letter suffix (uppercase)" do
      # Note: Parser normalizes letter suffixes to uppercase
      identifier = Pubid::Nist.parse("NIST SP 800-53 Rev. 5a")
      expect(identifier.to_s).to eq("NIST SP 800-53 Rev. 5A")
    end

    it "preserves r format with letter suffix (uppercase)" do
      # Note: Parser normalizes letter suffixes to uppercase
      identifier = Pubid::Nist.parse("NIST SP 800-53 r5a")
      expect(identifier.to_s).to eq("NIST SP 800-53 r5A")
    end
  end

  describe "long notation references (issue #155)" do
    # Long notation uses "Rev." / "Part." prefixes with optional separators
    # between the prefix and the digit. Short form ("r1", "pt1") is unaffected.

    it "parses 'Rev.1' (period, no space)" do
      identifier = Pubid::Nist.parse("NIST SP 800-67 Rev.1")
      expect(identifier.to_s).to eq("NIST SP 800-67 Rev.1")
    end

    it "parses 'Rev. 1' (period and space — already supported)" do
      identifier = Pubid::Nist.parse("NIST SP 800-67 Rev. 1")
      expect(identifier.to_s).to eq("NIST SP 800-67 Rev. 1")
    end

    it "parses 'Part. 1' (period and space)" do
      identifier = Pubid::Nist.parse("NIST SP 800-57 Part. 1")
      expect(identifier.to_s).to eq("NIST SP 800-57pt1")
    end

    it "parses 'Part.1' (period, no space)" do
      identifier = Pubid::Nist.parse("NIST SP 800-57 Part.1")
      expect(identifier.to_s).to eq("NIST SP 800-57pt1")
    end

    it "parses 'Part 1' (space, no period — already supported)" do
      identifier = Pubid::Nist.parse("NIST SP 800-57 Part 1")
      expect(identifier.to_s).to eq("NIST SP 800-57pt1")
    end

    it "round-trips 'Rev.1' form through parse-serialize-parse" do
      original = "NIST SP 800-67 Rev.1"
      first = Pubid::Nist.parse(original)
      expect(first.to_s).to eq(original)
      expect(Pubid::Nist.parse(first.to_s).to_s).to eq(original)
    end
  end
end
