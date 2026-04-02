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
end
