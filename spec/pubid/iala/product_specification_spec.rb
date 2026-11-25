# frozen_string_literal: true

require "spec_helper"
require "pubid/iala"

# IALA's S-100-family product specifications — the S-201..S-299 range
# IHO granted IALA (iala.int, "IALA S-200 Product Specification and
# Development Status": "This range, which spans from S-201 to S-299, is
# compliant with the IHO S-100 standard … granted the numbering series
# S-201 to S-299 through IHO approval").
#
# The official MRN form follows the iala flavor's scheme — IALA
# Recommendation R1023 (Maritime Resource Names; its own cover prints
# urn:mrn:iala:pub:r1023:ed1.0) and Guideline G1143 (Unique Identifiers
# for Maritime Resources, Annex A4: urn:mrn:iala:pub:<managed name
# spaces>) — with the S-100-family faces: the hyphenated lowercase doc
# id ("s-201") and the dotted x.y.z edition after the same ed marker.
RSpec.describe Pubid::Iala::Identifiers::ProductSpecification do
  describe ".parse" do
    {
      # The canonical bare face — iala.int's own citation form.
      "S-201 2.0.0" => "S-201 2.0.0",
      "S-201" => "S-201",
      "S-201 1.1.0" => "S-201 1.1.0",
      # The draft face (the site's "S-201 Product Specification Draft
      # 0.0.7 July 2017" spelling carries the same dotted edition).
      "S-201 0.0.7" => "S-201 0.0.7",
      # Other granted-range members (the dev-status pages: S-210, S-211,
      # S-212, S-230, S-240, S-245, S-246, S-247).
      "S-230 1.0.0" => "S-230 1.0.0",
      "S-247 0.2.0 (E)" => "S-247 0.2.0 (E)",
      # The prefixed spellings normalize: the designation carries no
      # publisher token, so the "IALA " prefix, the "Ed" marker and the
      # compact ":ed" form all parse to the bare face. The lower-case
      # code spelling is the site-URL shape; it binds the typed form,
      # never the codeless slug.
      "IALA S-201 2.0.0" => "S-201 2.0.0",
      "IALA S-201 Ed 2.0.0" => "S-201 2.0.0",
      "IALA S-201:ed2.0.0" => "S-201 2.0.0",
      "IALA s-201 2.0.0" => "S-201 2.0.0",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Iala.parse(input).to_s).to eq(canonical)
      end
    end

    it "keeps the edition verbatim (the S-100 dotted x.y.z)" do
      expect(Pubid::Iala.parse("S-201 2.0.0").edition).to eq("2.0.0")
    end

    it "keys the index on the bare number" do
      expect(Pubid::Iala.parse("S-201 2.0.0").root.number).to eq("201")
    end

    it "prints no publisher prefix (the designation rule)" do
      id = Pubid::Iala.parse("S-201 2.0.0")
      expect(id.publisher_prefixes).to eq([])
      expect(id.to_s(with_publisher: true)).to eq("S-201 2.0.0")
      expect(id.to_s(with_publisher: false)).to eq("S-201 2.0.0")
    end
  end

  describe "rejection" do
    [
      # Outside the granted range: 200 is excluded ("spans from S-201"),
      # other hundreds digits are other orgs' grants.
      "S-200 1.0.0",
      "S-411 1.2.1",   # WMO's grant
      "S-101 1.0.0",   # IHO's S-1xx family
      # Not the granted three-digit shape.
      "S-30 2.0",
      "S-2011 2.0.0",
      # An edition needs a value.
      "S-201 Ed",
    ].each do |input|
      it "rejects #{input.inspect}" do
        expect { Pubid::Iala.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  describe "#to_urn" do
    it "names the S-100 family in the official MRN scheme" do
      expect(Pubid::Iala.parse("S-201 2.0.0").to_urn)
        .to eq("urn:mrn:iala:pub:s-201:ed2.0.0")
    end

    it "carries the language letter" do
      expect(Pubid::Iala.parse("S-247 0.2.0 (E)").to_urn)
        .to eq("urn:mrn:iala:pub:s-247:ed0.2.0:e")
    end

    it "round-trips the URN through the parser" do
      urn = "urn:mrn:iala:pub:s-201:ed2.0.0"
      id = Pubid::Iala.parse(urn)
      expect(id.to_urn).to eq(urn)
      expect(id.to_s).to eq("S-201 2.0.0")
    end
  end

  describe "pubid-scheme URN" do
    it "round-trips through the codec" do
      id = Pubid::Iala.parse("S-201 2.0.0")
      expect(Pubid.parse_urn(id.to_pubid_urn)).to eq(id)
    end
  end

  describe "routing (the dual-perspective reclaim)" do
    # The bare S-lexical form names a different document per org
    # (pubid#469/#763): the hundreds digit is the grant. IALA's exact
    # round trip on the bare face reclaims the S-2xx strings the WMO
    # flavor's generic S-rule used to capture.
    it "routes the bare S-2xx form to IALA" do
      id = Pubid.parse("S-201 2.0.0")
      expect(id).to be_a(described_class)
      expect(id.to_urn).to eq("urn:mrn:iala:pub:s-201:ed2.0.0")
    end

    it "leaves WMO's S-4xx with WMO" do
      id = Pubid.parse("S-411 1.2.1")
      expect(id).to be_a(Pubid::Wmo::Identifiers::Standard)
      expect(id.to_urn).to eq("urn:mrn:wmo:pub:s-411:ed1.2.1")
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    %w[
      S-201
      S-201\ 2.0.0
      S-230\ 1.0.0\ (E)
      S-201\ ANNEX\ B2
    ].each do |code|
      it "round-trips #{code.inspect}" do
        id = Pubid::Iala.parse(code)
        restored = Pubid::Iala::Identifier.from_hash(id.to_hash)
        expect(restored).to eq(id)
        expect(restored.class).to eq(id.class)
        expect(restored.to_hash).to eq(id.to_hash)
      end
    end
  end
end
