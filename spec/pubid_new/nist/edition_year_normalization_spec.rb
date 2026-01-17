# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Edition Year Normalization" do
  describe "converts dash-year to edition-year format" do
    it "normalizes simple number with year" do
      identifier = PubidNew::Nist.parse("NBS CIRC 11-1911")
      expect(identifier.to_s).to eq("NBS CIRC 11e1911")
    end

    it "normalizes number with year (2-digit)" do
      identifier = PubidNew::Nist.parse("NBS CIRC 74-1937")
      expect(identifier.to_s).to eq("NBS CIRC 74e1937")
    end

    it "normalizes modern identifier with year" do
      identifier = PubidNew::Nist.parse("NIST SP 330-2019")
      expect(identifier.to_s).to eq("NIST SP 330e2019")
    end

    it "does not normalize patterns with existing edition (e2-YYYY)" do
      # This pattern has an existing edition indicator (e2) followed by a year
      # The fix now correctly preserves the edition number and renders with CIRC dot notation
      identifier = PubidNew::Nist.parse("NBS CIRC 11e2-1915")
      expect(identifier.to_s).to eq("NBS CIRC 11e2.1915")
    end
  end

  describe "round-trip fidelity for normalized patterns" do
    it "maintains format through parse-serialize-parse cycle" do
      original = "NBS CIRC 11e1911"
      first = PubidNew::Nist.parse(original)
      serialized = first.to_s
      second = PubidNew::Nist.parse(serialized)

      expect(serialized).to eq(original)
      expect(second.to_s).to eq(original)
    end

    it "maintains format for modern identifiers" do
      original = "NIST SP 330e2019"
      first = PubidNew::Nist.parse(original)
      serialized = first.to_s
      second = PubidNew::Nist.parse(serialized)

      expect(serialized).to eq(original)
      expect(second.to_s).to eq(original)
    end
  end

  describe "V2 normalization patterns are MORE correct than V1" do
    # Per design document, V2's normalization patterns are superior:
    # - Edition year: -YYYY → eYYYY (more explicit)
    # These must be preserved
    it "preserves eYYYY format (not reverting to -YYYY)" do
      identifier = PubidNew::Nist.parse("NIST SP 330e2019")
      expect(identifier.to_s).to include("e2019")
      expect(identifier.to_s).not_to include("-2019")
    end
  end
end
