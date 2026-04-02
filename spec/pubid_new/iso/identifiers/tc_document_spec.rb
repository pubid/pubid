# frozen_string_literal: true

require "rspec"
require_relative "../../../../lib/pubid_new/iso"

RSpec.describe PubidNew::Iso::Identifiers::TcDocument do
  describe "#parse" do
    it "parses TC document with SC and WG" do
      id = PubidNew::Iso.parse("ISO/TC 184/SC 4/WG 3 N 123")
      expect(id).to be_a(described_class)
      expect(id.tc_type.value).to eq("TC")
      expect(id.tc_number.value).to eq("184")
      expect(id.sc_type.value).to eq("SC")
      expect(id.sc_number.value).to eq("4")
      expect(id.wg_type.value).to eq("WG")
      expect(id.wg_number.value).to eq("3")
      expect(id.number.value).to eq("123")
    end

    it "parses simple TC document" do
      id = PubidNew::Iso.parse("ISO/TC 184 N 100")
      expect(id).to be_a(described_class)
      expect(id.tc_type.value).to eq("TC")
      expect(id.tc_number.value).to eq("184")
      expect(id.number.value).to eq("100")
      expect(id.sc_type).to be_nil
      expect(id.wg_type).to be_nil
    end

    it "parses JTC document" do
      id = PubidNew::Iso.parse("ISO/JTC 1 N 456")
      expect(id).to be_a(described_class)
      expect(id.tc_type.value).to eq("JTC")
      expect(id.tc_number.value).to eq("1")
      expect(id.number.value).to eq("456")
    end

    it "parses TC document with year" do
      id = PubidNew::Iso.parse("ISO/TC 184 N 100:2024")
      expect(id).to be_a(described_class)
      expect(id.number.value).to eq("100")
      expect(id.date.year).to eq("2024")
    end

    it "parses TC document with TC and SC only" do
      id = PubidNew::Iso.parse("ISO/TC 184/SC 4 N 789")
      expect(id).to be_a(described_class)
      expect(id.tc_type.value).to eq("TC")
      expect(id.tc_number.value).to eq("184")
      expect(id.sc_type.value).to eq("SC")
      expect(id.sc_number.value).to eq("4")
      expect(id.wg_type).to be_nil
      expect(id.number.value).to eq("789")
    end
  end

  describe "#to_s" do
    it "renders TC document with SC and WG" do
      id = PubidNew::Iso.parse("ISO/TC 184/SC 4/WG 3 N 123")
      expect(id.to_s).to eq("ISO/TC 184/SC 4/WG 3 N 123")
    end

    it "renders simple TC document" do
      id = PubidNew::Iso.parse("ISO/TC 184 N 100")
      expect(id.to_s).to eq("ISO/TC 184 N 100")
    end

    it "renders JTC document" do
      id = PubidNew::Iso.parse("ISO/JTC 1 N 456")
      expect(id.to_s).to eq("ISO/JTC 1 N 456")
    end

    it "renders TC document with year" do
      id = PubidNew::Iso.parse("ISO/TC 184 N 100:2024")
      expect(id.to_s).to eq("ISO/TC 184 N 100:2024")
    end

    it "renders TC document with TC and SC only" do
      id = PubidNew::Iso.parse("ISO/TC 184/SC 4 N 789")
      expect(id.to_s).to eq("ISO/TC 184/SC 4 N 789")
    end
  end

  describe "#to_urn" do
    it "generates URN for TC document with SC and WG" do
      id = PubidNew::Iso.parse("ISO/TC 184/SC 4/WG 3 N 123")
      expect(id.to_urn).to eq("urn:iso:doc:iso:tc:184:sc-4:wg-3:123")
    end

    it "generates URN for simple TC document" do
      id = PubidNew::Iso.parse("ISO/TC 184 N 100")
      expect(id.to_urn).to eq("urn:iso:doc:iso:tc:184:100")
    end

    it "generates URN for JTC document" do
      id = PubidNew::Iso.parse("ISO/JTC 1 N 456")
      expect(id.to_urn).to eq("urn:iso:doc:iso:tc:1:456")
    end

    it "generates URN for TC document with TC and SC only" do
      id = PubidNew::Iso.parse("ISO/TC 184/SC 4 N 789")
      expect(id.to_urn).to eq("urn:iso:doc:iso:tc:184:sc-4:789")
    end
  end

  describe "#type" do
    it "returns correct type information" do
      expect(described_class.type[:key]).to eq(:tc)
      expect(described_class.type[:title]).to eq("Technical Committee Document")
      expect(described_class.type[:short]).to eq("TC")
    end
  end

  describe "#typed_stages" do
    it "returns empty array for TC documents" do
      expect(described_class.typed_stages).to eq([])
    end
  end

  describe "#==" do
    it "compares TC documents correctly" do
      id1 = PubidNew::Iso.parse("ISO/TC 184 N 100")
      id2 = PubidNew::Iso.parse("ISO/TC 184 N 100")
      expect(id1).to eq(id2)
    end

    it "distinguishes different TC documents" do
      id1 = PubidNew::Iso.parse("ISO/TC 184 N 100")
      id2 = PubidNew::Iso.parse("ISO/TC 184 N 101")
      expect(id1).not_to eq(id2)
    end

    it "distinguishes TC from non-TC documents" do
      tc_id = PubidNew::Iso.parse("ISO/TC 184 N 100")
      std_id = PubidNew::Iso.parse("ISO 9001:2015")
      expect(tc_id).not_to eq(std_id)
    end
  end
end
