# frozen_string_literal: true

require "spec_helper"

# The ISO pilot of the pubid-scheme URN (issue #656). The official
# urn:iso:std: form stays on #to_urn and is not touched here.
RSpec.describe "ISO pubid-scheme URN" do
  def urn_of(string)
    Pubid::Iso.parse(string).to_pubid_urn
  end

  def expect_round_trip(string)
    id = Pubid::Iso.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "ISO 9001" => "urn:pubid:iso:is:9001",
    "ISO 9001:2015" => "urn:pubid:iso:is:9001:year-2015",
    "ISO/IEC 27001:2013" => "urn:pubid:iso:is:27001:co-IEC:year-2013",
    "ISO/IEC/IEEE 8802-3:2021" =>
      "urn:pubid:iso:is:8802:co-IEC,IEEE:part-3:year-2021",
    "ISO 10303-11:1994" => "urn:pubid:iso:is:10303:part-11:year-1994",
    "ISO/TR 23455:2019" => "urn:pubid:iso:tr:23455:year-2019",
    "ISO/DIS 9001" => "urn:pubid:iso:is:9001:stage-dis",
    "ISO 9001:2015/Amd 1:2016" =>
      "urn:pubid:iso:is:9001:year-2015:amd:1:year-2016",
    "ISO 9001:2015/Amd 1:2016/Cor 1:2017" =>
      "urn:pubid:iso:is:9001:year-2015:amd:1:year-2016:cor:1:year-2017",
    "ISO 9001 (all parts)" => "urn:pubid:iso:all:ids-(iso:is:9001)",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(urn_of(input)).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  it "keeps a language spelling as a facet in the trailing f group" do
    expect(urn_of("ISO 9001:2015(E)"))
      .to eq("urn:pubid:iso:is:9001:year-2015:lang-en:f:0.langsrc-E")
    expect_round_trip("ISO 9001:2015(E)")
  end

  it "keeps an edition spelling as a facet" do
    urn = urn_of("ISO 14442:2006 Ed 2")
    expect(urn).to eq("urn:pubid:iso:is:14442:year-2006:ed-2:f:0.edsrc-Ed~202")
    expect_round_trip("ISO 14442:2006 Ed 2")
  end

  it "writes a facet against the node it belongs to" do
    urn = urn_of("ISO/IEC DIR 1 ISO SUP Ed 13")
    expect(urn).to match(/:f:1\.edsrc-Ed~2013\z/)
    expect_round_trip("ISO/IEC DIR 1 ISO SUP Ed 13")
  end

  it "round-trips a bundled directive with its supplement" do
    expect_round_trip("ISO/IEC DIR 1 + IEC SUP")
  end

  # An absent value leaves no segment and never an empty slot: in a slug,
  # "::" would become "//", which servers collapse.
  it "emits no empty segment for an amendment without a number" do
    base = Pubid::Iso.parse("ISO 9001:2015")
    amd = Pubid::Iso::Identifiers::Amendment.new(base: base, year: "2016")
    urn = amd.to_pubid_urn
    expect(urn).to eq("urn:pubid:iso:is:9001:year-2015:amd:year-2016")
    expect(Pubid.parse_urn(urn).to_hash).to eq(amd.to_hash)
  end

  it "escapes a core value that would read as structure" do
    id = Pubid::Iso::Identifiers::InternationalStandard.new(number: "amd")
    expect(id.to_pubid_urn).to eq("urn:pubid:iso:is:~61md")
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
  end

  # The escape of a core value must not depend on which schemas exist: a
  # published slug must keep its meaning when a type token, an atom or a
  # flavor schema is added later.
  describe "schema-independent escape of a core value" do
    {
      "iec.is" => "~69ec.is",  # reads as a qualified token
      "foo-1" => "~66oo-1",    # reads as an atom
      "x" => "~78",            # reads as a type token
      "802.11" => "802.11",    # a dotted number stays as it is
      "G.711" => "G.711",
      "800-53" => "800-53",
    }.each do |number, core|
      it "writes the number #{number} as #{core}" do
        id = Pubid::Iso::Identifiers::InternationalStandard.new(number: number)
        expect(id.to_pubid_urn).to eq("urn:pubid:iso:is:#{core}")
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end
    end
  end

  it "places a locality, which serializes as a component" do
    id = Pubid::Iso.parse("ISO 9001:2015")
    id.locality = Pubid::Components::Locality.new(value: "3")
    expect(id.to_pubid_urn).to eq("urn:pubid:iso:is:9001:year-2015:loc-3")
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
  end

  it "round-trips a list that holds an empty string" do
    id = Pubid::Iso::Identifiers::InternationalStandard
      .new(number: "1", copublishers: ["IEC", "", "IEEE"])
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
  end

  it "parses a long URN that it emits" do
    id = Pubid::Iso::Identifiers::InternationalStandard.new(number: "標" * 120)
    expect(id.to_pubid_urn.length).to be > Pubid::MAX_INPUT_LENGTH
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
  end

  describe "strict parse" do
    it "refuses invalid UTF-8 with a URN error" do
      bad = (+"urn:pubid:iso:is:\xff").force_encoding("UTF-8")
      expect { Pubid.parse_urn(bad) }
        .to raise_error(Pubid::Errors::UrnParseError)
      prefix = (+"urn:pubid\xff:iso").force_encoding("UTF-8")
      expect { Pubid.parse_pubid_urn(prefix) }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "raises a URN error when a value cannot be cast" do
      expect { Pubid.parse_urn("urn:pubid:iso:is:1:undated-maybe") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses an atom out of canonical order" do
      expect { Pubid.parse_urn("urn:pubid:iso:is:9001:year-2015:part-1") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses an unknown atom" do
      expect { Pubid.parse_urn("urn:pubid:iso:is:9001:colour-red") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses a duplicate atom" do
      expect { Pubid.parse_urn("urn:pubid:iso:is:9001:year-2015:year-2016") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses an unknown type token" do
      expect { Pubid.parse_urn("urn:pubid:iso:nope:9001") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses an empty segment" do
      expect { Pubid.parse_urn("urn:pubid:iso:is::9001") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses an escape the canonical form does not need" do
      expect { Pubid.parse_urn("urn:pubid:iso:is:~39001") }
        .to raise_error(Pubid::Errors::UrnParseError, /canonical/)
    end

    it "refuses the type-metadata URN, which names a type and no document" do
      expect { Pubid.parse_urn("urn:pubid:iso:type:is") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses a flavor that has no pubid-scheme schema yet" do
      expect { Pubid.parse_urn("urn:pubid:nosuchflavor:x:1") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end
  end

  it "accepts only the pubid scheme in Pubid.parse_pubid_urn" do
    expect { Pubid.parse_pubid_urn("urn:iso:std:iso:9001") }
      .to raise_error(Pubid::Errors::UrnParseError)
    expect(Pubid.parse_pubid_urn("urn:pubid:iso:is:9001").to_s)
      .to eq("ISO 9001")
  end

  it "leaves the official URN on #to_urn unchanged" do
    expect(Pubid::Iso.parse("ISO/IEC 27001:2013").to_urn)
      .to eq("urn:iso:std:iso-iec:27001")
  end
end
