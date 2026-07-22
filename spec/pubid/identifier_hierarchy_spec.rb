require "spec_helper"

RSpec.describe "Identifier hierarchy contract" do
  # Every flavor now exposes its abstract base as a real class named
  # Pubid::<Flavor>::Identifier (the unified pattern). Flavors that historically
  # used Identifiers::Base / SingleIdentifier keep those as backward-compatible
  # aliases or subclasses, but Identifier is the canonical, uniform handle.
  let(:flavor_identifier_bases) do
    {
      Amca: Pubid::Amca::Identifier,
      Ansi: Pubid::Ansi::Identifier,
      Api: Pubid::Api::Identifier,
      Ashrae: Pubid::Ashrae::Identifier,
      Asme: Pubid::Asme::Identifier,
      Astm: Pubid::Astm::Identifier,
      Bsi: Pubid::Bsi::Identifier,
      Ccsds: Pubid::Ccsds::Identifier,
      CenCenelec: Pubid::CenCenelec::Identifier,
      Cie: Pubid::Cie::Identifier,
      Csa: Pubid::Csa::Identifier,
      Etsi: Pubid::Etsi::Identifier,
      Idf: Pubid::Idf::Identifier,
      Iec: Pubid::Iec::Identifier,
      Ieee: Pubid::Ieee::Identifier,
      Iho: Pubid::Iho::Identifier,
      Iso: Pubid::Iso::Identifier,
      Itu: Pubid::Itu::Identifier,
      Jcgm: Pubid::Jcgm::Identifier,
      Jis: Pubid::Jis::Identifier,
      Nist: Pubid::Nist::Identifier,
      Oiml: Pubid::Oiml::Identifier,
      Plateau: Pubid::Plateau::Identifier,
      Sae: Pubid::Sae::Identifier,
    }
  end

  it "every flavor's Identifier is a real class" do
    non_class = flavor_identifier_bases.reject { |_f, klass| klass.is_a?(Class) }
    expect(non_class).to be_empty,
                         "Flavor Identifiers that are not classes: #{non_class.keys.join(', ')}"
  end

  it "every flavor's Identifier inherits (directly or indirectly) from Pubid::Identifier" do
    missing = flavor_identifier_bases.reject do |_flavor, klass|
      klass < ::Pubid::Identifier
    end
    expect(missing).to be_empty,
                       "Bases not inheriting from Pubid::Identifier: #{missing.keys.join(', ')}"
  end

  it "no flavor identifier class inherits Lutaml::Model::Serializable directly" do
    direct_lutaml = flavor_identifier_bases.select do |_flavor, klass|
      klass.superclass == ::Lutaml::Model::Serializable
    end
    expect(direct_lutaml).to be_empty,
                             "Bases bypassing hierarchy via direct Lutaml::Model::Serializable: #{direct_lutaml.keys.join(', ')}"
  end

  # The core guarantee of the unification: a parsed identifier of any flavor is
  # `is_a?(Pubid::<Flavor>::Identifier)` — so a consumer handed the flavor's
  # Identifier class (e.g. relaton-index's pubid_class) can identity-check it.
  describe "parsed identifiers are is_a? their flavor Identifier" do
    samples = {
      Amca: "AMCA 200", Ansi: "ANSI 802.3-2012", Api: "API BULL 11L2",
      Ashrae: "ASHRAE 55-2017", Asme: "ASME B18.3-2012", Astm: "ASTM ADJD2148",
      Bsi: "BS 5839-1:2017", Ccsds: "CCSDS 100.0-G-1", CenCenelec: "EN 50128:2011",
      Cie: "CIE 198:2011", Csa: "CSA C22.2 NO. 0:20",
      Etsi: "ETSI EG 200 053 V1.5.1 (2004-06)", Idf: "IDF 146:2003",
      Iec: "IEC 60050:2011", Ieee: "IEEE 802.3-2018", Iho: "IHO S-57",
      Iso: "ISO 9001:2015", Itu: "ITU-T G.711", Jcgm: "JCGM 100:2008",
      Jis: "JIS A 0001:1999", Nist: "NIST IR 88-4008", Oiml: "OIML R 138",
      Plateau: "PLATEAU Handbook #00", Sae: "SAE J1939"
    }

    samples.each do |flavor, ref|
      it "#{flavor}: #{ref}" do
        mod = Pubid.const_get(flavor)
        id = mod.parse(ref)
        expect(id).to be_a(mod::Identifier)
        expect(mod::Identifier === id).to be(true)
      end
    end
  end

  describe "Pubid::Identifier instance methods available on every flavor" do
    let(:sample_identifier) { Pubid::Iso::Identifier.parse("ISO 9001:2015") }

    it "responds to to_urn" do
      expect(sample_identifier).to respond_to(:to_urn)
    end

    it "responds to to_hash" do
      expect(sample_identifier).to respond_to(:to_hash)
    end

    it "responds to exclude" do
      expect(sample_identifier).to respond_to(:exclude)
    end

    it "responds to hash" do
      expect(sample_identifier).to respond_to(:hash)
    end

    it "responds to eql?" do
      expect(sample_identifier).to respond_to(:eql?)
    end
  end

  describe "BSI unified hierarchy" do
    it "Bsi::Identifier is the single abstract base" do
      expect(Pubid::Bsi::Identifier.superclass).to eq(::Pubid::Identifier)
    end

    it "SingleIdentifier is a back-compat alias for Identifier" do
      expect(Pubid::Bsi::SingleIdentifier).to equal(Pubid::Bsi::Identifier)
    end

    it "Amendment inherits from the base" do
      expect(Pubid::Bsi::Identifiers::Amendment.superclass).to eq(Pubid::Bsi::Identifier)
    end

    it "Corrigendum inherits from the base" do
      expect(Pubid::Bsi::Identifiers::Corrigendum.superclass).to eq(Pubid::Bsi::Identifier)
    end

    it "Bsi::Identifiers::Base is not defined" do
      expect(defined?(Pubid::Bsi::Identifiers::Base)).to be_nil
    end
  end

  # `Identifiers::Base` is a legacy name that only survives where it is still a
  # *real* intermediate class (Category B). Category-A flavors, whose `Base` was
  # merely `Base = Identifier`, no longer define it at all — `Identifier` is the
  # only handle. This guards against a Category-A alias creeping back.
  describe "Identifiers::Base presence by category" do
    # Category B: `Base` is a genuine intermediate class carrying shared
    # single-document attributes; wrappers deliberately bypass it. Kept.
    category_b = %i[Iec Asme Api Astm Csa Ccsds CenCenelec]

    # Category A: `Base` was a pure alias for `Identifier`. Removed.
    category_a = %i[
      Amca Ashrae Etsi Gost Iala Ietf Iho Itu Nist Plateau Sae Ieee
    ]
    # (Adobe/Easc are also Category A but not registered in every build; covered
    # implicitly — they simply must not define Identifiers::Base either.)

    category_b.each do |flavor|
      it "#{flavor}: Identifiers::Base is a real class, distinct" do
        mod = Pubid.const_get(flavor)
        expect(defined?(mod::Identifiers::Base)).to eq("constant")
        expect(mod::Identifiers::Base).to be_a(Class)
        expect(mod::Identifiers::Base).not_to equal(mod::Identifier)
        expect(mod::Identifiers::Base).to be < mod::Identifier
      end
    end

    category_a.each do |flavor|
      it "#{flavor}: Identifiers::Base is not defined (unified)" do
        mod = Pubid.const_get(flavor)
        expect(defined?(mod::Identifiers::Base)).to be_nil
      end
    end
  end
end
