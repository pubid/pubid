# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Identifier#to_all_parts" do
  def roundtrip(id)
    id.class.from_hash(id.to_hash)
  end

  context "with ISO" do
    let(:id) { Pubid::Iso.parse("ISO 9000-1:2015") }
    let(:all) { id.to_all_parts }

    it "renders the all-parts reference and keeps the date" do
      expect(all.to_s).to eq("ISO 9000:2015 (all parts)")
    end

    it "sets all_parts and removes the part" do
      expect(all.all_parts).to be true
      expect(all.part).to be_nil
      expect(all.year).to eq("2015")
    end

    it "returns a new identifier of the same class" do
      expect(all).to be_an_instance_of(id.class)
      expect(all).not_to equal(id)
    end

    it "does not change the receiver" do
      all
      expect(id.all_parts).to be false
      expect(id.to_s).to eq("ISO 9000-1:2015")
    end

    it "removes the subpart" do
      sub = Pubid::Iso.parse("ISO 17301-1-2:2016").to_all_parts
      expect([sub.part, sub.subpart]).to eq([nil, nil])
      expect(sub.to_s).to eq("ISO 17301:2016 (all parts)")
    end

    it "chains with exclude to remove the date" do
      expect(all.exclude(:date).to_s).to eq("ISO 9000 (all parts)")
    end

    it "matches every part of the document with ===" do
      expect(all === Pubid::Iso.parse("ISO 9000-2:2015")).to be true
      expect(all === id).to be true
    end

    it "survives a hash round trip" do
      expect(roundtrip(all)).to eq(all)
    end
  end

  context "with IEC" do
    let(:all) { Pubid::Iec.parse("IEC 80000-1").to_all_parts }

    it "renders the all-parts reference and the series URN" do
      expect(all.to_s).to eq("IEC 80000 (all parts)")
      expect(all.to_urn).to eq("urn:iec:std:iec:80000:::ser")
    end
  end

  context "with a parts collection" do
    {
      "ETSI TS 129 198-4 V1.1.1 (2002-01)" => Pubid::Etsi,
      "3GPP TS 29.198-04-1" => Pubid::Tgpp,
      "JIS B 0001-1:2019" => Pubid::Jis,
    }.each do |ref, flavor|
      it "empties parts of #{ref}" do
        all = flavor.parse(ref).to_all_parts
        expect(all.parts).to eq([])
        expect(all.all_parts).to be true
      end
    end

    # JIS serializes all_parts, so the empty parts collection must survive.
    it "survives a hash round trip with an empty parts collection" do
      all = Pubid::Jis.parse("JIS B 0001-1:2019").to_all_parts
      expect(roundtrip(all)).to eq(all)
    end

    it "empties the parts inside an ITU code" do
      all = Pubid::Itu.parse("ITU-R P.838-3").to_all_parts
      expect(all.code.parts).to eq([])
      expect(all.all_parts).to be true
    end
  end

  # One identifier per registered flavor. Only a few flavors print
  # "(all parts)" or serialize the flag, so this checks the object only.
  context "with every registered flavor" do
    Pubid.eager_load_flavors!
    Pubid::Registry.flavor_names.each do |flavor|
      it "#{flavor} returns an all-parts copy without a part" do
        klass = Pubid::Registry.get(flavor)::Identifier
        all = klass.new(number: "1", part: "2").to_all_parts
        expect(all).to be_an_instance_of(klass)
        expect(all.part).to be_nil
        expect(all.all_parts).to be true
      end
    end
  end

  it "keeps the date when a flavor has no part" do
    all = Pubid::Iso.parse("ISO 9000:2015").to_all_parts
    expect(all.to_s).to eq("ISO 9000:2015 (all parts)")
  end
end
