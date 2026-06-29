require "spec_helper"

RSpec.describe "Identifier hierarchy contract" do
  let(:flavor_identifier_bases) do
    {
      Amca: Pubid::Amca::Identifiers::Base,
      Ansi: Pubid::Ansi::Identifier,
      Api: Pubid::Api::Identifiers::Base,
      Ashrae: Pubid::Ashrae::Identifiers::Base,
      Asme: Pubid::Asme::Identifiers::Base,
      Astm: Pubid::Astm::Identifiers::Base,
      Bsi: Pubid::Bsi::SingleIdentifier,
      Ccsds: Pubid::Ccsds::Identifiers::Base,
      CenCenelec: Pubid::CenCenelec::Identifiers::Base,
      Cie: Pubid::Cie::Identifier,
      Csa: Pubid::Csa::Identifiers::Base,
      Etsi: Pubid::Etsi::Identifiers::Base,
      Idf: Pubid::Idf::Identifier,
      Iec: Pubid::Iec::Identifiers::Base,
      Ieee: Pubid::Ieee::Identifiers::Base,
      Iho: Pubid::Iho::Identifiers::Base,
      Iso: Pubid::Iso::Identifier,
      Itu: Pubid::Itu::Identifiers::Base,
      Jcgm: Pubid::Jcgm::Identifier,
      Jis: Pubid::Jis::Identifier,
      Nist: Pubid::Nist::Identifiers::Base,
      Oiml: Pubid::Oiml::Identifier,
      Plateau: Pubid::Plateau::Identifiers::Base,
      Sae: Pubid::Sae::Identifiers::Base,
    }
  end

  it "every flavor's identifier base inherits (directly or indirectly) from Pubid::Identifier" do
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
    it "Bsi::SingleIdentifier is the single abstract base" do
      expect(Pubid::Bsi::SingleIdentifier.superclass).to eq(::Pubid::Identifier)
    end

    it "Amendment inherits from SingleIdentifier" do
      expect(Pubid::Bsi::Identifiers::Amendment.superclass).to eq(Pubid::Bsi::SingleIdentifier)
    end

    it "Corrigendum inherits from SingleIdentifier" do
      expect(Pubid::Bsi::Identifiers::Corrigendum.superclass).to eq(Pubid::Bsi::SingleIdentifier)
    end

    it "Bsi::Identifiers::Base is removed" do
      expect(defined?(Pubid::Bsi::Identifiers::Base)).to be_nil
    end
  end
end
