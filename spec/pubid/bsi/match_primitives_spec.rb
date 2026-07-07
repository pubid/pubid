# frozen_string_literal: true

# Phase 2 specs for the pubid-driven matching primitives relaton-bsi needs to
# retire its regex/peeling helpers: #base_document, reducing #exclude
# (:amendment/:supplement/:edition), a uniform supplement interface, and
# #matches?.
RSpec.describe "Pubid::Bsi match primitives" do
  def parse(string)
    Pubid::Bsi.parse(string)
  end

  describe "#base_document" do
    it "peels an amendment to the bare standard" do
      expect(parse("BS 7273-4:2015+A1:2021").base_document.to_s)
        .to eq("BS 7273-4:2015")
    end

    it "peels a corrigendum to the bare standard" do
      expect(parse("BS 1234:2015+C1:2016").base_document.to_s)
        .to eq("BS 1234:2015")
    end

    it "peels Expert Commentary to the bare standard" do
      expect(parse("BS EN ISO 13485 Expert Commentary").base_document.to_s)
        .to eq("BS EN ISO 13485")
    end

    it "peels a Flex edition to the bare standard" do
      expect(parse("BSI Flex 0 v2.0").base_document.to_s).to eq("BSI Flex 0")
    end

    it "returns self for a plain identifier" do
      expect(parse("BS 5266-1:2016").base_document.to_s).to eq("BS 5266-1:2016")
    end
  end

  describe "reducing #exclude" do
    it "exclude(:edition) drops the Flex edition" do
      expect(parse("BSI Flex 0 v2.0").exclude(:edition).to_s)
        .to eq("BSI Flex 0")
    end

    it "exclude(:amendment) reduces a consolidated id to its base" do
      expect(parse("BS 7273-4:2015+A1:2021").exclude(:amendment).to_s)
        .to eq("BS 7273-4:2015")
    end

    it "exclude(:supplement) drops a corrigendum too" do
      expect(parse("BS 1234:2015+C1:2016").exclude(:supplement).to_s)
        .to eq("BS 1234:2015")
    end

    it "exclude(:date, :amendment) is equal across years and amendments" do
      expect(parse("BS 7273-4:2015+A1:2021").exclude(:date, :amendment))
        .to eq(parse("BS 7273-4:2018+A2:2020").exclude(:date, :amendment))
    end
  end

  describe "uniform supplement interface" do
    it "exposes amendment fields via the supplement_* interface" do
      supp = parse("BS 7273-4:2015+A1:2021").identifiers.last
      expect(supp.supplement_type).to eq(:amendment)
      expect(supp.supplement_number).to eq("1")
      expect(supp.supplement_year).to eq(2021)
    end

    it "exposes corrigendum fields via the supplement_* interface" do
      supp = parse("BS 1234:2015+C1:2016").identifiers.last
      expect(supp.supplement_type).to eq(:corrigendum)
      expect(supp.supplement_number).to eq("1")
      expect(supp.supplement_year).to eq(2016)
    end
  end

  describe "#matches?" do
    it "matches two references differing only in year when ignoring date" do
      expect(parse("BS EN ISO 8848").matches?(parse("BS EN ISO 8848:2022"),
                                              ignore: [:date])).to be(true)
    end

    it "does not match different parts" do
      expect(parse("BS 5266-1").matches?(parse("BS 5266-2"),
                                         ignore: [:date])).to be(false)
    end

    it "matches base documents when the amendment is dropped" do
      query = parse("BS 7273-4:2015+A1:2021")
      hit = parse("BS 7273-4:2018+A3:2022")
      expect(query.base_document.matches?(hit.base_document, ignore: [:date]))
        .to be(true)
    end
  end
end
