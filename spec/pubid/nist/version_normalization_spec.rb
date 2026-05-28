# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Version Normalization" do
  describe "V2 normalization patterns are MORE correct than V1" do
    # Per design document, V2's version normalization is superior:
    # - Version: vX.Y/Ver. X.Y → verX.Y (consistent lowercase format)
    # These must be preserved

    it "normalizes short v format to verbose ver format" do
      identifier = Pubid::Nist.parse("NIST SP 500-268v1.1")
      expect(identifier.to_s).to eq("NIST SP 500-268ver1.1")
    end

    it "normalizes Ver. with period to ver format" do
      identifier = Pubid::Nist.parse("NIST SP 800-60 Ver. 2.0")
      expect(identifier.to_s).to eq("NIST SP 800-60ver2.0")
    end

    it "preserves already-normalized ver format" do
      identifier = Pubid::Nist.parse("NIST SP 800-53ver1.1")
      expect(identifier.to_s).to eq("NIST SP 800-53ver1.1")
    end

    it "handles multi-digit versions" do
      identifier = Pubid::Nist.parse("NIST SP 800-60ver2.0")
      expect(identifier.to_s).to eq("NIST SP 800-60ver2.0")
    end
  end

  describe "round-trip fidelity for normalized versions" do
    it "maintains format through parse-serialize-parse cycle" do
      original = "NIST SP 500-268ver1.1"
      first = Pubid::Nist.parse(original)
      serialized = first.to_s
      second = Pubid::Nist.parse(serialized)

      expect(serialized).to eq(original)
      expect(second.to_s).to eq(original)
    end

    it "maintains format for Ver.-normalized versions" do
      original = "NIST SP 800-60ver2.0"
      first = Pubid::Nist.parse(original)
      serialized = first.to_s
      second = Pubid::Nist.parse(serialized)

      expect(serialized).to eq(original)
      expect(second.to_s).to eq(original)
    end
  end

  describe "V2 format is more consistent" do
    it "uses lowercase ver consistently" do
      identifier = Pubid::Nist.parse("NIST SP 800-60 Ver. 2.0")
      expect(identifier.to_s).to match(/ver\d+\.\d+/)
      expect(identifier.to_s).not_to match(/Ver\./)
      expect(identifier.to_s).not_to match(/\bv\d+\.\d+/)
    end
  end
end
