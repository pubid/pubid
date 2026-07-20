# frozen_string_literal: true

require "spec_helper"
require "pubid"

RSpec.describe Pubid::Cie::SupplementIdentifier do
  describe "inheritance" do
    it "Corrigendum and Supplement inherit from SupplementIdentifier" do
      expect(Pubid::Cie.parse("CIE 232:2019/Cor1:2020")).to be_a(described_class)
      expect(Pubid::Cie.parse("CIE 121-SP1:2009")).to be_a(described_class)
    end
  end

  describe "nested base_identifier (like ISO/IEC/BSI/JCGM)" do
    it "wraps a Standard base and exposes base_document" do
      sup = Pubid::Cie.parse("CIE 121-SP1:2009")
      expect(sup).to be_a(Pubid::Cie::Identifiers::Supplement)
      expect(sup.base_identifier).to be_a(Pubid::Cie::Identifiers::Standard)
      expect(sup.base_document.to_s).to eq("CIE 121:2009")
      expect(sup.drop_supplements.to_s).to eq("CIE 121:2009")
      expect(sup.supplement_type).to eq(:supplement)
      expect(sup.supplement_number).to eq("1")
    end

    it "keeps the base's stage/language on the nested Standard" do
      sup = Pubid::Cie.parse("CIE DIS 025-SP1/E:2019")
      expect(sup.base_identifier.stage).to eq("DIS")
      expect(sup.base_identifier.language.code).to eq("E")
      expect(sup.to_s).to eq("CIE DIS 025-SP1/E:2019")
    end

    it "corrigendum wraps a Standard base with a clean trailing suffix" do
      cor = Pubid::Cie.parse("CIE 232:2019/Cor1:2020")
      expect(cor).to be_a(Pubid::Cie::Identifiers::Corrigendum)
      expect(cor.base_identifier).to be_a(Pubid::Cie::Identifiers::Standard)
      expect(cor.base_document.to_s).to eq("CIE 232:2019")
      expect(cor.supplement_type).to eq(:corrigendum)
      expect(cor.supplement_number).to eq("1")
    end

    it "corrigendum of a supplement nests two levels and peels to the root" do
      cor = Pubid::Cie.parse("CIE 198-SP1.4:2011/Cor1:2013")
      expect(cor.base_identifier).to be_a(Pubid::Cie::Identifiers::Supplement)
      expect(cor.drop_supplements.to_s).to eq("CIE 198-SP1.4:2011")
      expect(cor.base_document.to_s).to eq("CIE 198:2011") # peels both layers
    end

    it "matches? its base document when the supplement layer is ignored" do
      cor = Pubid::Cie.parse("CIE 232:2019/Cor1:2020")
      base = Pubid::Cie.parse("CIE 232:2019")
      expect(cor.matches?(base, ignore: [:supplement])).to be true
    end
  end

  describe "round-trip with a nested base:" do
    %w[
      CIE\ 121-SP1:2009
      CIE\ DIS\ 025-SP1/E:2019
      CIE\ 232:2019/Cor1:2020
      CIE\ 198-SP1.4:2011/Cor1:2013
    ].each do |id|
      it "#{id} round-trips through from_hash(to_hash) with a nested base" do
        parsed = Pubid::Cie.parse(id)
        h = parsed.to_hash
        expect(h["base_identifier"]).to be_a(Hash)
        expect(h["base_identifier"]["_type"]).to start_with("pubid:cie:")
        restored = Pubid::Cie::Identifier.from_hash(h)
        expect(restored.to_s).to eq(id)
        expect(restored.to_hash).to eq(h)
      end
    end
  end
end
