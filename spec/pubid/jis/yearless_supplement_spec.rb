# frozen_string_literal: true

require "spec_helper"

# A JIS amendment with no year used to render a dangling colon —
# "JIS G 0558/AMD 1:" — a form the grammar rejects, so the year-omitted
# render of a parsed amendment could not re-parse (issue #745, the class
# relaton's JIS corpus fuzz kept harvesting). The renderer now prints no
# colon at all when the year is absent, and the grammar takes the
# supplement's ":year[R]" tail as one optional unit: renderer and grammar
# agree on "…/AMD 1", and the bare trailing colon stays rejected.
RSpec.describe "JIS yearless supplements (issue #745)" do
  describe "parsing a yearless amendment" do
    subject(:id) { Pubid::Jis::Identifier.parse("JIS G 0558/AMD 1") }

    it "parses as Amendment" do
      expect(id).to be_a(Pubid::Jis::Identifiers::Amendment)
    end

    it "parses the base without a year" do
      expect(id.base.series).to eq("G")
      expect(id.base.number).to eq("0558")
      expect(id.base.year).to be_nil
    end

    it "keeps the amendment number and leaves the year nil (not 0)" do
      expect(id.number).to eq(1)
      expect(id.year).to be_nil
    end

    it "renders without a dangling colon" do
      expect(id.to_s).to eq("JIS G 0558/AMD 1")
    end

    it "round-trips through parse" do
      expect(Pubid::Jis::Identifier.parse(id.to_s)).to eq(id)
    end

    it "round-trips through the hash" do
      expect(Pubid::Jis::Identifier.from_hash(id.to_hash)).to eq(id)
    end

    it "carries no year key in the hash" do
      expect(id.to_hash).not_to have_key("year")
    end

    it "serializes a yearless URN that decodes back to the same hash" do
      expect(id.to_pubid_urn).to eq("urn:pubid:jis:jis:0558:series-G:amd:1")
      expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
    end

    it "renders without publisher" do
      expect(id.to_s(with_publisher: false)).to eq("G 0558/AMD 1")
    end
  end

  describe "parsing a yearless corrigendum" do
    subject(:id) { Pubid::Jis::Identifier.parse("JIS B 3700-11:1996/CORRIGENDUM 1") }

    it "parses as Corrigendum" do
      expect(id).to be_a(Pubid::Jis::Identifiers::Corrigendum)
    end

    it "keeps the base year and a nil amendment year" do
      expect(id.base.year).to eq(1996)
      expect(id.year).to be_nil
    end

    it "renders without a dangling colon" do
      expect(id.to_s).to eq("JIS B 3700-11:1996/CORRIGENDUM 1")
    end

    it "round-trips through parse and hash" do
      expect(Pubid::Jis::Identifier.parse(id.to_s)).to eq(id)
      expect(Pubid::Jis::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end

  describe "a yearless reaffirmed amendment" do
    subject(:id) { Pubid::Jis::Identifier.parse("JIS G 0558/AMD 1R") }

    it "renders the bare R after the number" do
      expect(id.to_s).to eq("JIS G 0558/AMD 1R")
    end

    it "round-trips through parse and hash" do
      expect(Pubid::Jis::Identifier.parse(id.to_s)).to eq(id)
      expect(Pubid::Jis::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end

  # The year-omission operation the corpus fuzz performs on an attested
  # row: exclude(:year) from a parsed amendment, render, re-parse.
  describe "the fuzz operation: excluding the year from a yearful amendment" do
    subject(:yearless) do
      Pubid::Jis::Identifier.parse("JIS G 0558/AMD 1:2012").exclude(:year)
    end

    it "renders the colon-less yearless form" do
      expect(yearless.to_s).to eq("JIS G 0558/AMD 1")
    end

    it "re-parses to an equal identifier" do
      expect(Pubid::Jis::Identifier.parse(yearless.to_s)).to eq(yearless)
    end

    it "keeps no year in the hash" do
      expect(yearless.to_hash).not_to have_key("year")
    end
  end

  # The rows relaton's jis-fuzz harvest names (without the trailing colon
  # the old renderer emitted): every one parses, renders and round-trips.
  {
    "JIS C 0364-4-43/AMD 1" => "C 0364-4-43/AMD 1",
    "JIS C 0806-1/AMD 1" => "C 0806-1/AMD 1",
    "JIS C 7709-2/AMD 11" => "C 7709-2/AMD 11",
    "JIS D 8103/AMD 1" => "D 8103/AMD 1",
    "JIS G 3443-1/AMD 1" => "G 3443-1/AMD 1",
    "JIS K 0552/AMD 1" => "K 0552/AMD 1",
    "JIS S 2149/AMD 2" => "S 2149/AMD 2",
    "JIS X 4153/AMD 2" => "X 4153/AMD 2",
    "JIS Z 4335/AMD 1" => "Z 4335/AMD 1",
  }.each do |input, internal|
    describe input do
      it "parses, renders the same string, and round-trips" do
        id = Pubid::Jis::Identifier.parse(input)

        expect(id.year).to be_nil
        expect(id.to_s).to eq(input)
        expect(Pubid::Jis::Identifier.parse(id.to_s)).to eq(id)
        expect(Pubid::Jis::Identifier.from_hash(id.to_hash)).to eq(id)
        expect(id.to_s(with_publisher: false)).to eq(internal)
      end
    end
  end

  # The dangling colon the old renderer emitted stays a parse failure:
  # the grammar takes colon and year as one unit, exactly like the base
  # face rejects "JIS G 0558:".
  {
    "ascii colon" => "JIS G 0558/AMD 1:",
    "full-width colon" => "JIS G 0558/AMD 1：",
    "reaffirmed with dangling colon" => "JIS G 0558/AMD 1:R",
    "yearless corrigendum with dangling colon" =>
      "JIS B 3700-11:1996/CORRIGENDUM 1:",
  }.each do |shape, input|
    it "rejects the dangling colon (#{shape})" do
      expect { Pubid::Jis::Identifier.parse(input) }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  describe "yearful faces are byte-identical" do
    # input => rendered form (AMENDMENT normalizes to AMD on render)
    {
      "JIS G 0558/AMD 1:2012" => "JIS G 0558/AMD 1:2012",
      "JIS G 0558:2004/AMD 1:2012" => "JIS G 0558:2004/AMD 1:2012",
      "JIS A 0001:1999/AMD 1:2000" => "JIS A 0001:1999/AMD 1:2000",
      "JIS X 0208:1997/AMENDMENT 1:2012" => "JIS X 0208:1997/AMD 1:2012",
      "JIS G 0558/AMD 1:2020R" => "JIS G 0558/AMD 1:2020R",
      "JIS Z 2248:2022/AMD 1:2022R" => "JIS Z 2248:2022/AMD 1:2022R",
      "JIS L 4107:2000R/AMD 1:2020" => "JIS L 4107:2000R/AMD 1:2020",
      "JIS B 3700-11:1996/CORRIGENDUM 1:2002" =>
        "JIS B 3700-11:1996/CORRIGENDUM 1:2002",
      "WES 3003(E):1995/AMENDMENT 1:2025" => "WES 3003(E):1995/AMD 1:2025",
    }.each do |input, rendered|
      it "renders #{input} as #{rendered}" do
        id = Pubid::Jis::Identifier.parse(input)

        expect(id.to_s).to eq(rendered)
        expect(id.year).not_to be_nil
        expect(Pubid::Jis::Identifier.parse(id.to_s)).to eq(id)
        expect(Pubid::Jis::Identifier.from_hash(id.to_hash)).to eq(id)
      end
    end

    it "renders JIS A 0001:1999/AMD 1:2000 without publisher" do
      expect(Pubid::Jis::Identifier.parse("JIS A 0001:1999/AMD 1:2000")
               .to_s(with_publisher: false)).to eq("A 0001:1999/AMD 1:2000")
    end

    it "renders WES 3003(E):1995/AMENDMENT 1:2025 without publisher" do
      expect(Pubid::Jis::Identifier
               .parse("WES 3003(E):1995/AMENDMENT 1:2025")
               .to_s(with_publisher: false))
        .to eq("WES 3003(E):1995/AMD 1:2025")
    end
  end
end
