# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::Base do
  describe "#weight" do
    context "basic identifier" do
      it "returns weight for simple identifier" do
        id = PubidNew::Nist.parse("NIST SP 800-53")
        expect(id.weight).to be > 0
      end

      it "returns higher weight for identifier with more attributes" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53")
        id2 = PubidNew::Nist.parse("NIST SP 800-53r5")

        expect(id2.weight).to be > id1.weight
      end
    end

    context "complex identifiers" do
      it "counts all defined attributes" do
        # Use valid NIST format with supplement (based on fixtures:
        # NBS HB 28supp1957pt1)
        id = PubidNew::Nist.parse("NIST SP 800-53r5supp1924")
        base_weight = id.weight

        # Each non-nil attribute adds to weight
        expect(base_weight).to be_a(Integer)
        expect(base_weight).to be > 5
      end
    end
  end

  describe "#merge" do
    context "merging basic attributes" do
      it "merges series from another document" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53")
        id2 = PubidNew::Nist.parse("NIST FIPS 199")

        merged = id1.merge(id2)
        expect(merged.series.to_s).to eq("FIPS")
      end

      it "merges number from another document" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53")
        id2 = PubidNew::Nist.parse("NIST SP 800-187")

        merged = id1.merge(id2)
        # Number is replaced entirely (not partially merged)
        expect(merged.number.value).to eq("800-187")
      end

      it "prefers higher edition value numerically" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53r3")
        id2 = PubidNew::Nist.parse("NIST SP 800-53r5")

        merged = id1.merge(id2)
        expect(merged.edition.to_s).to eq("r5")
      end

      it "does not override if new edition is lower numerically" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53r5")
        id2 = PubidNew::Nist.parse("NIST SP 800-53r3")

        merged = id1.merge(id2)
        expect(merged.edition.to_s).to eq("r5")
      end
    end

    context "merging special attributes" do
      it "merges supplement attribute" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53")
        # Use valid NIST supplement format - simple number without dash
        # Based on fixtures: NIST SP 305supp20, NIST SP 955supp2002
        id2 = PubidNew::Nist.parse("NIST SP 187supp1924")

        merged = id1.merge(id2)
        expect(merged.supplement).not_to be_nil
        expect(merged.supplement).not_to be_empty
      end

      it "merges errata attribute" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53")
        id2 = PubidNew::Nist.parse("NIST SP 800-53errata")

        merged = id1.merge(id2)
        expect(merged.errata).to eq("errata")
      end

      it "returns self for method chaining" do
        id1 = PubidNew::Nist.parse("NIST SP 800-53")
        id2 = PubidNew::Nist.parse("NIST SP 800-187")

        result = id1.merge(id2)
        expect(result).to eq(id1)
      end
    end

    context "with non-NIST document" do
      it "returns self unchanged" do
        id = PubidNew::Nist.parse("NIST SP 800-53")
        iso_id = PubidNew::Iso.parse("ISO 9001")

        merged = id.merge(iso_id)
        expect(merged).to eq(id)
      end
    end
  end
end
