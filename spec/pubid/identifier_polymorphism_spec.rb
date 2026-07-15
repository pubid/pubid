# frozen_string_literal: true

require "spec_helper"

# Replaces the former identifier_facade_spec. The per-flavor `Identifier` module
# facades (NIST, IHO, ASHRAE, BSI, CEN/CENELEC) and the standalone-class
# factories (AMCA, ITU, PLATEAU, IEEE, …) are now real Pubid::Identifier
# subclasses, so the identity and polymorphic-from_hash contract a consumer
# (e.g. relaton-index's pubid_class) relies on holds natively — no facade mixin.
# These specs pin that contract on the real classes.
RSpec.describe "Identifier class polymorphism contract" do
  # Flavors that were previously the module-facade / gated set. Every one now
  # answers `is_a?` / `===` through its real Identifier class.
  identity_samples = {
    Amca: "AMCA 200",
    Ashrae: "ASHRAE 55-2017",
    Bsi: "BS 5839-1:2017",
    CenCenelec: "EN 50128:2011",
    Iho: "IHO S-57",
    Ieee: "IEEE 802.3-2018",
    Itu: "ITU-T G.711",
    Nist: "NIST IR 88-4008",
    Plateau: "PLATEAU Handbook #00",
  }.freeze

  describe "identity check (is_a? / ===)" do
    identity_samples.each do |flavor, ref|
      context "#{flavor} (#{ref})" do
        let(:klass) { Pubid.const_get(flavor)::Identifier }
        let(:id)    { klass.parse(ref) }

        it "the parsed identifier is_a? the flavor Identifier class" do
          expect(id).to be_a(klass)
        end

        it "the flavor Identifier class === the parsed identifier" do
          expect(klass === id).to be true
        end

        it "the flavor Identifier exposes from_hash" do
          expect(klass).to respond_to(:from_hash)
        end
      end
    end
  end

  # Polymorphic from_hash routes the serialized `_type` back to the concrete
  # subclass. Only flavors with a clean to_hash/from_hash round-trip are checked
  # here; the rest are tracked (pending) in identifier_roundtrip_spec.rb.
  describe "polymorphic from_hash round-trip" do
    clean = {
      Ashrae: "ASHRAE 55-2017",
      Bsi: "BS 5839-1:2017",
      CenCenelec: "EN 50128:2011",
      Iho: "IHO S-57",
      Nist: "NIST IR 88-4008",
      Plateau: "PLATEAU Handbook #00",
    }.freeze

    clean.each do |flavor, ref|
      context "#{flavor} (#{ref})" do
        let(:klass) { Pubid.const_get(flavor)::Identifier }
        let(:id)    { klass.parse(ref) }

        it "from_hash returns the same concrete class parse produced" do
          expect(klass.from_hash(id.to_hash).class).to eq(id.class)
        end

        it "from_hash round-trips to_s" do
          expect(klass.from_hash(id.to_hash).to_s).to eq(id.to_s)
        end
      end
    end
  end

  # The relaton-index contract: a consumer is handed Pubid::Nist::Identifier as
  # pubid_class, validates `value.is_a?(pubid_class)` on save and rebuilds via
  # `pubid_class.from_hash(raw)` on load.
  describe "relaton-index pubid_class contract (NIST)" do
    let(:pubid_class) { Pubid::Nist::Identifier }
    let(:id)          { pubid_class.parse("NIST IR 88-4008") }

    it "the id is_a? the pubid_class on save" do
      expect(id).to be_a(pubid_class)
    end

    it "pubid_class.from_hash rebuilds the concrete id on load" do
      rebuilt = pubid_class.from_hash(id.to_hash)
      expect(rebuilt.class).to eq(id.class)
      expect(rebuilt.to_s).to eq(id.to_s)
    end

    it "an unknown _type falls back to the flavor base class" do
      base = pubid_class.from_hash("_type" => "pubid:nist:unknown-type")
      expect(base).to be_a(Pubid::Nist::Identifier)
    end
  end

  describe "cross-flavor polymorphic dispatch" do
    it "root Pubid::Identifier.from_hash dispatches by _type to a flavor class" do
      require "pubid/iso"
      hash = { "_type" => "pubid:iso:technical-report",
               "number" => "25901", "part" => "1", "year" => "2016" }
      resolved = Pubid::Identifier.from_hash(hash)
      expect(resolved).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
      expect(resolved.to_s).to eq("ISO/TR 25901-1:2016")
    end

    it "from_hash on a flavor base dispatches a nested adopted identifier" do
      require "pubid/gost"
      outer = { "_type" => "pubid:gost:identical-adoption",
                "number" => "58904",
                "year" => "2020",
                "base" => { "_type" => "pubid:gost:national-standard",
                            "number" => "58904", "year" => "2020" },
                "adopted" => { "_type" => "pubid:iso:technical-report",
                               "number" => "25901", "part" => "1",
                               "year" => "2016" } }
      restored = Pubid::Gost::Identifier.from_hash(outer)
      expect(restored).to be_a(Pubid::Gost::Identifiers::IdenticalAdoption)
      expect(restored.adopted).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
      expect(restored.to_s).to eq("GOST R 58904-2020/ISO/TR 25901-1:2016")
    end
  end
end
