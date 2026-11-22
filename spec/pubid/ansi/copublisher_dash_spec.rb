# frozen_string_literal: true

require "spec_helper"

# The dash after the co-publisher acronym: "ANSI/ISA-5.1-2009". The dash is
# spelling (`number_separator`), a second dash group carries the year after a
# part, and TIA ends the number with a revision letter.
RSpec.describe "ANSI dash form after the co-publisher" do
  def parse(string)
    Pubid::Ansi.parse(string)
  end

  {
    "ANSI/ISA-5.1-2009" => { copublisher: "ISA", number: "5.1", part: nil,
                             year: "2009", revision: nil },
    "ANSI/ANS-8.1-2014" => { copublisher: "ANS", number: "8.1", part: nil,
                             year: "2014", revision: nil },
    "ANSI/ISA-61511-1-2018" => { copublisher: "ISA", number: "61511",
                                 part: "1", year: "2018", revision: nil },
    "ANSI/TIA-568.2-D" => { copublisher: "TIA", number: "568.2", part: nil,
                            year: nil, revision: "D" },
  }.each do |input, expected|
    context input do
      let(:id) { parse(input) }

      it "reads the attributes" do
        expect(id.copublishers.map(&:body)).to eq([expected[:copublisher]])
        expect(id.number).to eq(expected[:number])
        expect(id.part).to eq(expected[:part])
        expect(id.year&.to_s).to eq(expected[:year])
        expect(id.revision).to eq(expected[:revision])
        expect(id.number_separator).to eq("-")
        expect(id.date_separator).to eq(expected[:year] ? "-" : nil)
      end

      it "renders back byte for byte" do
        expect(id.to_s).to eq(input)
      end

      it "round-trips through the hash" do
        back = Pubid::Ansi::Identifier.from_hash(id.to_hash)
        expect(back).to eq(id)
        expect(back.to_s).to eq(input)
      end

      it "round-trips through the pubid URN" do
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end

      it "is routed to ANSI by Pubid.parse" do
        routed = Pubid.parse(input)
        expect(routed).to be_a(Pubid::Ansi::Identifier)
        expect(routed.to_s).to eq(input)
      end

      it "drops the publisher group without a leading separator" do
        stripped = id.to_s(with_publisher: false)
        expect(stripped).to start_with(expected[:number])
      end
    end
  end

  it "treats the dash and the space spelling as one document" do
    expect(parse("ANSI/ISA-5.1-2009")).to eq(parse("ANSI/ISA 5.1-2009"))
  end

  it "keeps the space spelling out of the hash" do
    expect(parse("ANSI/ISA 5.1-2009").to_hash)
      .not_to have_key("number_separator")
  end

  it "keeps the number separator when the year is excluded" do
    id = parse("ANSI/ISA-5.1-2009").exclude(:year)
    expect(id.to_s).to eq("ANSI/ISA-5.1")
  end

  it "finds a dated edition from a bare reference" do
    expect(parse("ANSI/ISA-5.1").matches?(parse("ANSI/ISA-5.1-2009"),
                                          ignore: [:year])).to be true
  end

  it "tells two revisions apart" do
    c = parse("ANSI/TIA-568.2-C")
    d = parse("ANSI/TIA-568.2-D")
    expect(c).not_to eq(d)
    expect(c.to_urn).not_to eq(d.to_urn)
    expect(c.to_pubid_urn).not_to eq(d.to_pubid_urn)
    expect(c.to_mr_string).not_to eq(d.to_mr_string)
  end

  it "keeps a year-like part before a revision as a part" do
    id = parse("ANSI/TIA-568-2009-D")
    expect([id.part, id.revision, id.date]).to eq(["2009", "D", nil])
    expect(id.to_s).to eq("ANSI/TIA-568-2009-D")
  end

  it "refuses a dash year followed by a colon year" do
    expect { parse("ANSI X9.8-1-2007:2009") }
      .to raise_error(Pubid::Errors::ParseError)
  end

  it "reads the dash year after a part in the space form too" do
    id = parse("ANSI X9.8-1-2007")
    expect([id.number, id.part, id.year.to_s]).to eq(["X9.8", "1", "2007"])
    expect(id.to_s).to eq("ANSI X9.8-1-2007")
  end

  it "does not take a revision letter that starts a word" do
    expect { parse("ANSI/TIA-568.2-DE") }.to raise_error(Pubid::Errors::ParseError)
  end
end
