# frozen_string_literal: true

RSpec.describe "Lutaml::Model serialization round-trip" do
  shared_examples "a round-trippable identifier" do |flavor, identifier_string|
    it "round-trips #{identifier_string} through to_hash/from_hash" do
      original = Pubid.const_get(flavor).parse(identifier_string)
      hash = original.to_hash
      restored = original.class.from_hash(hash)
      expect(restored.to_s).to eq(original.to_s)
    end
  end

  describe "ISO" do
    include_examples "a round-trippable identifier", :Iso, "ISO 9001:2015"
    include_examples "a round-trippable identifier", :Iso,
                     "ISO/IEC 17031-1:2020"
    include_examples "a round-trippable identifier", :Iso, "ISO 4"
  end

  describe "supplements (nested base_identifier)" do
    it "Amendment has nested base_identifier with _type discriminator" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      hash = id.to_hash

      expect(hash).to have_key("base_identifier")
      expect(hash["base_identifier"]["_type"]).to eq("pubid:iso:international-standard")
      expect(hash["base_identifier"]["number"]["value"]).to eq("9001")
    end

    it "round-trips Amendment with base_identifier" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      hash = id.to_hash
      restored = id.class.from_hash(hash)

      expect(restored.class).to eq(Pubid::Iso::Identifiers::Amendment)
      expect(restored.base_identifier.class).to eq(Pubid::Iso::Identifiers::InternationalStandard)
      expect(restored.base_identifier.number.value).to eq("9001")
      expect(restored.number.value).to eq("1")
    end

    it "round-trips 3-level nesting (Corrigendum → Amendment → InternationalStandard)" do
      id = Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
      hash = id.to_hash
      restored = id.class.from_hash(hash)

      expect(restored.class).to eq(Pubid::Iso::Identifiers::Corrigendum)
      expect(restored.base_identifier.class).to eq(Pubid::Iso::Identifiers::Amendment)
      expect(restored.base_identifier.base_identifier.class).to eq(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "3-level nesting has _type discriminator at each level" do
      id = Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
      hash = id.to_hash

      expect(hash["_type"]).to eq("pubid:iso:corrigendum")
      expect(hash["base_identifier"]["_type"]).to eq("pubid:iso:amendment")
      expect(hash["base_identifier"]["base_identifier"]["_type"]).to eq("pubid:iso:international-standard")
    end
  end

  describe "MR string" do
    it "renders basic identifier" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      expect(id.to_mr_string).to eq("ISO.9001.2015")
    end

    it "renders with part" do
      id = Pubid::Iso.parse("ISO/IEC 17031-1:2020")
      expect(id.to_mr_string).to eq("ISO/IEC.17031-1.2020")
    end

    it "renders undated" do
      id = Pubid::Iso.parse("ISO 9001")
      expect(id.to_mr_string).to eq("ISO.9001")
    end

    it "parses MR string back to identifier" do
      id = Pubid::Parsers::MrString.parse("ISO.9001.2015")
      expect(id.to_s).to eq("ISO 9001:2015")
    end

    it "parses MR string with part" do
      id = Pubid::Parsers::MrString.parse("IEC.61131-3.2013")
      expect(id.to_s).to eq("IEC 61131-3:2013")
    end
  end

  describe "exclude" do
    it "removes date attribute" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      excluded = id.exclude(:date)
      expect(excluded.date).to be_nil
      expect(excluded.number.value).to eq("9001")
    end
  end
end
