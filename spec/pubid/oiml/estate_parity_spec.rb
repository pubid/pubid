# frozen_string_literal: true

require "spec_helper"

# The oiml-pubid estate grammar's conformance corpus (pubid/pubid-ts#63),
# ported as the parity gate for retiring @oimlsmart/oiml-pubid: the
# publication-family cases, the CS family, the language-marker forms, and
# the rejections the estate grammar enforces.
RSpec.describe "OIML estate parity (pubid/pubid-ts#63)" do
  def parse(id)
    Pubid::Oiml.parse(id)
  end

  describe "publication and CS families" do
    {
      "OIML R 60-2:2021" => Pubid::Oiml::Identifiers::Recommendation,
      "OIML R 60" => Pubid::Oiml::Identifiers::Recommendation,
      "OIML R 7" => Pubid::Oiml::Identifiers::Recommendation,
      "OIML B 18:2025(E)" => Pubid::Oiml::Identifiers::BasicPublication,
      "OIML R 60-1:2021(E)" => Pubid::Oiml::Identifiers::Recommendation,
      "OIML B 10-1:2004 (F)" => Pubid::Oiml::Identifiers::BasicPublication,
      "OIML D 11:2013(E/F)" => Pubid::Oiml::Identifiers::Document,
      "OIML B 14:2006 (Fra)" => Pubid::Oiml::Identifiers::BasicPublication,
      "OIML B 12:2004 (A)" => Pubid::Oiml::Identifiers::BasicPublication,
      "OIML D 11:2013" => Pubid::Oiml::Identifiers::Document,
      "OIML G 21:2017" => Pubid::Oiml::Identifiers::Guide,
      "OIML E 6:2011" => Pubid::Oiml::Identifiers::ExpertReport,
      "OIML S 6:2011" => Pubid::Oiml::Identifiers::SeminarReport,
      "OIML S 6:2011(en)" => Pubid::Oiml::Identifiers::SeminarReport,
      "OIML E 5 6th Edition 2015 (E)" => Pubid::Oiml::Identifiers::ExpertReport,
      "OIML D 2 Edition 1999 (E)" => Pubid::Oiml::Identifiers::Document,
      "OIML-CS PD-05 Edition 6 (Amendment 1)" =>
        Pubid::Oiml::Identifiers::CertificationSystem,
      "OIML-CS PD-01 Edition 3" => Pubid::Oiml::Identifiers::CertificationSystem,
      "OIML-CS OD-01 Edition 4" => Pubid::Oiml::Identifiers::CertificationSystem,
      "OIML-CS OD-02 Edition 3" => Pubid::Oiml::Identifiers::CertificationSystem,
      "OIML-CS CID-01 Edition 6" => Pubid::Oiml::Identifiers::CertificationSystem,
      "OIML-CS PD 05 Edition 6" => Pubid::Oiml::Identifiers::CertificationSystem,
      "OIML R 138:2009 Amendment 1" => Pubid::Oiml::Identifiers::Amendment,
    }.each do |input, klass|
      it "round-trips #{input.inspect}" do
        id = parse(input)
        expect(id).to be_a(klass)
        expect(id.to_s).to eq(input)
      end
    end
  end

  describe "language markers" do
    it "keeps the printed spelling verbatim" do
      expect(parse("OIML B 14:2006 (Fra)").language).to eq("Fra")
      expect(parse("OIML B 12:2004 (A)").language).to eq("A")
      expect(parse("OIML S 6:2011(en)").language).to eq("en")
    end

    it "lowercases the marker in the URN" do
      expect(parse("OIML B 14:2006 (Fra)").to_urn).to eq("urn:oiml:b:14:2006:fra")
    end
  end

  describe "CS certification-system documents" do
    it "keeps the zero-padded number and the family" do
      id = parse("OIML-CS PD-05 Edition 6 (Amendment 1)")
      expect(id.family).to eq("PD")
      expect(id.number).to eq("05")
      expect(id.edition).to eq("6")
      expect(id.amendment).to eq("1")
    end

    it "records the space-separated spelling" do
      expect(parse("OIML-CS PD 05 Edition 6").space_separator).to be(true)
      expect(parse("OIML-CS PD-05 Edition 6").space_separator).to be(false)
    end

    it "urns the family-number pair" do
      expect(parse("OIML-CS PD-05 Edition 6 (Amendment 1)").to_urn)
        .to eq("urn:oiml:cs:pd-05")
    end
  end

  describe "trailing amendment ordinal" do
    it "keeps the ordinal and resolves the urn through the base year" do
      id = parse("OIML R 138:2009 Amendment 1")
      expect(id.number).to eq("1")
      expect(id.trailing).to be(true)
      expect(id.to_urn).to eq("urn:oiml:r:138:2009:1")
    end
  end

  describe "rejections" do
    [
      "Some Other Document",
      "OIML X 99", # X is not an OIML family letter
      "OIML R 60 extra words here",
      "OIML-CS XX-01 Edition 1", # XX is not a CS family
      "ISO 9001:2015",
    ].each do |input|
      it "rejects #{input.inspect}" do
        expect { parse(input) }.to raise_error(Pubid::Errors::ParseError)
      end
    end
  end
end
