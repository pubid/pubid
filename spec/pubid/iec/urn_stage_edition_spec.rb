# frozen_string_literal: true

require "spec_helper"

# The IEC URN used to be produced by a regex scraped over `identifier.to_s`.
# Three things followed from that:
#
#   * the stage was fused into the publisher slot ("urn:iec:std:iec-np:..."),
#   * the edition was never emitted at all, and
#   * the regex was unanchored, so any type token outside its hard-coded list
#     ate the publisher ("IEC/DTS 62271-1" -> "urn:iec:std:dts:62271-1::::",
#     and every "IECEE TRF ..." keyed "urn:iec:std:trf:...").
#
# The generator now builds from the identifier's own components. The slot
# ORDER is unchanged, because the published relaton-data-iec corpus uses it:
#
#   urn:iec:std:{pub}[-{copub}]:{number}[-{part}]:{date}:{S7}:{S8}:{lang}
#
# S7 holds the stage when the document is not published, else the legacy type
# token. S8 holds the deliverable, else the edition. The published corpus
# contains no stage and no edition, so neither slot moves for any published
# row.
#
# See https://github.com/pubid/pubid/issues/360 item 4.
RSpec.describe "IEC URN stage and edition slots" do
  describe "the stage slot" do
    {
      # The identifier and the URN the issue asks for, verbatim.
      "IEC PNW 1000-1:2023 ED2" => "urn:iec:std:iec:1000-1:2023:stage-10.20:ed-2:",
      # CD carries the correspondence table's own code (30.20 "Draft
      # circulated as CD", data/iec/stage-codes.md) — the slot the
      # pubid-ts#187 parity round found the mirror already emitting and
      # the folded 30.00 lead contradicted (pubid#787; #733 is the same
      # ruling for the TR/TS/PAS point rows).
      "IEC CD 60038" => "urn:iec:std:iec:60038::stage-30.20::",
      "IEC NP 60038" => "urn:iec:std:iec:60038::stage-10.00::",
      "IEC FDIS 60038" => "urn:iec:std:iec:60038::stage-50.00::",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iec.parse(input).to_urn).to eq(urn)
      end
    end

    it "keeps the stage out of the publisher slot" do
      expect(Pubid::Iec.parse("IEC CD 60038").to_urn)
        .not_to include("iec-cd")
    end

    # A draft of a typed document has both a type and a stage, and one slot to
    # hold them. Both are kept, type first, because dropping the type would
    # collide a draft TS with a draft TR and with a draft International
    # Standard — the harmonized codes are shared across types.
    describe "a draft of a typed document keeps both" do
      it "renders a draft Technical Specification" do
        expect(Pubid::Iec.parse("IEC DTS 62271-1").to_urn)
          .to eq("urn:iec:std:iec:62271-1::ts-stage-50.00::")
      end

      it "renders a committee draft Technical Report" do
        expect(Pubid::Iec.parse("IEC CD TR 62048").to_urn)
          .to eq("urn:iec:std:iec:62048::tr-stage-30.20::")
      end

      it "does not collide a draft TR with a draft TS" do
        expect(Pubid::Iec.parse("IEC CD TR 62048").to_urn)
          .not_to eq(Pubid::Iec.parse("IEC CD TS 62048").to_urn)
      end
    end
  end

  describe "the edition slot" do
    {
      "IEC 60038:2009 ED7" => "urn:iec:std:iec:60038:2009::ed-7:",
      "IEC 62394 ED4" => "urn:iec:std:iec:62394:::ed-4:",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iec.parse(input).to_urn).to eq(urn)
      end
    end

    # A deliverable code owns the slot; the edition yields to it.
    it "prefers the deliverable code over the edition" do
      expect(Pubid::Iec.parse("IEC 60529:1989+AMD1:1999 CSV").to_urn)
        .to eq("urn:iec:std:iec:60529:1989::csv::plus:amd:1:1999")
    end
  end

  describe "the publisher slot" do
    {
      "IEC/DTS 62271-1" => "iec",
      "IEC/DTR 61000-1" => "iec",
      "IEC DPAS 62975" => "iec",
      "IECEE TRF 10079-1A:2020" => "iecee",
      "ISO/IEC PAS 62975" => "iso-iec",
    }.each do |input, head|
      it "keeps #{head.inspect} as the publisher of #{input.inspect}" do
        expect(Pubid::Iec.parse(input).to_urn.split(":")[3]).to eq(head)
      end
    end

    # "IEC CA" is one publisher body with a space in it. The old scrape took
    # the last whitespace-delimited token, and the published corpus records
    # "urn:iec:std:ca:01:2017:::" for it. Keeping that spelling is what keeps
    # those published rows byte-identical; do not "correct" it to "iec-ca"
    # without migrating the data.
    it "keeps the published spelling of a space-bearing publisher" do
      expect(Pubid::Iec.parse("IEC CA 01:2017").to_urn)
        .to eq("urn:iec:std:ca:01:2017:::")
    end
  end

  describe "round-tripping through parse_urn" do
    [
      "urn:iec:std:iec:1000-1:2023:stage-10.20:ed-2:",
      "urn:iec:std:iec:60038::stage-30.20::",
      "urn:iec:std:iec:62271-1::ts-stage-50.00::",
      "urn:iec:std:iec:62048::tr-stage-30.20::",
      "urn:iec:std:iec:60038:2009::ed-7:",
    ].each do |urn|
      it "round-trips #{urn.inspect}" do
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end
    end
  end

  # The pubid-ts#187 parity round (pubid#787): the mirror used to mint
  # different official URNs for the same identifier on the corpus-absent
  # draft-supplement faces — `stage-dcor` / `stage-dish` in its slot where
  # the gem leaves the slot empty. The EMPTY slot is the attested shape:
  # the testsuite ledger records `urn:iec:std:iec:60038-1::::::cor:1:` for
  # the CDCOR row and `...::::::ish:1:` for the DISH rows (the stage sits
  # on the supplement layer, and the slot reads the root document), and
  # IEC's table names no DCOR row at all. These pins hold the gem's
  # emission, which the mirror now follows.
  describe "the draft-supplement faces keep the attested empty stage slot" do
    {
      "IEC 60038-1/DCOR 1" => "urn:iec:std:iec:60038-1::::::cor:1:",
      "IEC/DCOR 60038-1" => "urn:iec:std:iec:60038-1::::::cor:1:",
      "IEC 60038-1/DISH 1" => "urn:iec:std:iec:60038-1::::::ish:1:",
      "IEC/DISH 60038-1" => "urn:iec:std:iec:60038-1::::::ish:1:",
      "IEC CDISH 60050-191" => "urn:iec:std:iec:60050-191::::::ish:1:",
      "IEC 60038-1/FDAM 1" => "urn:iec:std:iec:60038-1::::::amd:1:",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iec.parse(input).to_urn).to eq(urn)
      end
    end
  end

  # A multi-language URN joins the codes with a hyphen. The parser used to
  # build a single Language whose code was the whole field, so "en-fr" came
  # back as one bogus language and rendered as "(en-fr)".
  describe "multi-language URNs" do
    it "splits the language field back into separate languages" do
      id = Pubid::Iec.parse_urn("urn:iec:std:iec:60050-102::::en-fr")

      expect(id.languages.map { |l| l.code.to_s }).to eq(%w[en fr])
      # IEC house style joins with "-" (pubid#491)
      expect(id.to_s).to include("(en-fr)")
    end
  end

  describe "work-programme registrations" do
    it "gives a PNW work programme a URN with its stage and edition" do
      expect(Pubid::Iec.parse("PNW 65-915 ED1").to_urn)
        .to eq("urn:iec:std:iec:65-915::stage-10.20:ed-1:")
    end
  end
end
