# frozen_string_literal: true

# The IEC fragment-ladder spellings are rejected at parse (pubid#731).
#
# "CDFRAG", "DFRAG", "FDFRAG", "PRF Frag", "PWI Frag" and the NP/ANW/WD
# " Frag" siblings used to parse into broken shapes: a fragment built
# WITHOUT its base designation (the ladder token in the primary type
# position — the input's designation, date and edition were dropped, the
# fragment rendered bare "/FRAG", which is itself unparseable, and the
# official URN was nil), and a fragment carrying a NON-PUBLISHED ladder
# stage (the token in a supplement layer — the renderer prints the
# published "/FRAG<n>" face only, so the stage was dropped at render and
# parse(to_s) != parse).
#
# No IEC source prints either shape: the gem fixtures, the testsuite
# ledger and the IEC/ISO Harmonized APIs data feeds (an empty <FRAG/>
# element plus <stdFragment> for the number) attest only the on-base
# "/FRAG<n>" notation of the published fragment, and the stage-codes
# extract (data/iec/stage-codes.md) has no ladder rows. So the spellings
# are rejected at parse — the #726/#727 ruling for unattested,
# un-renderable faces — with from_hash left open for stored data.
RSpec.describe "IEC fragment-ladder spellings rejected at parse" do
  describe "the ladder spellings raise at parse" do
    # The five spellings of pubid#731, the NP/ANW/WD " Frag" siblings from
    # the same TYPED_STAGES ladder, the published "FRAG" token in the same
    # broken primary position, and the spellings that drop the most
    # (part, edition, date, language).
    raising = [
      "IEC CDFRAG 60038", "IEC DFRAG 60038", "IEC FDFRAG 60038",
      "IEC PRF Frag 60038", "IEC PWI Frag 60038",
      "IEC NP Frag 60038", "IEC ANW Frag 60038", "IEC WD Frag 60038",
      # even the published token in the primary position builds the same
      # base-less fragment (the designation goes nowhere)
      "IEC FRAG 60038",
      # with a part, slash-prefixed, with an edition/date/language
      "IEC CDFRAG 60038-1", "IEC/DFRAG 60038",
      "IEC DFRAG 60038 ED2", "IEC DFRAG 60038:2024",
      "IEC DFRAG 60038 ED2(en)"
    ].freeze

    raising.each do |input|
      it "raises for #{input.inspect}" do
        expect { Pubid::Iec.parse(input) }
          .to raise_error(Pubid::Errors::ParseError, /fragment-ladder/)
      end
    end

    it "reports the input and flavor on the synthetic raise" do
      expect { Pubid::Iec.parse("IEC CDFRAG 60038") }
        .to raise_error(Pubid::Errors::ParseError) do |error|
          expect(error.input).to eq("IEC CDFRAG 60038")
          expect(error.flavor).to eq("iec")
          expect(error.parse_failure_cause).to be_nil
        end
    end

    it "raises through the Pubid.parse prefix routing" do
      expect { Pubid.parse("IEC DFRAG 60038") }
        .to raise_error(Pubid::Errors::ParseError, /fragment-ladder/)
    end
  end

  describe "a ladder stage in a supplement layer raises too" do
    # The token in a supplement or second-supplement layer builds a
    # base-carrying fragment whose stage has no printed face: the renderer
    # prints the published "/FRAG<n>" token only, so the stage was dropped
    # at render and parse(to_s) != parse. Same un-renderable-facet ruling
    # as #727.
    ["IEC 60038/CDFRAG 1", "IEC 60038/AMD1/CDFRAG1"].each do |input|
      it "raises for #{input.inspect}" do
        expect { Pubid::Iec.parse(input) }
          .to raise_error(Pubid::Errors::ParseError, /fragment-ladder/)
      end
    end
  end

  describe "a broken fragment under a wrapper raises too" do
    # "IEC DFRAG 60038 (all parts)" is an AllParts identifier over the
    # base-less fragment; the walk descends through the members.
    it "raises for the all-parts spelling" do
      expect { Pubid::Iec.parse("IEC DFRAG 60038 (all parts)") }
        .to raise_error(Pubid::Errors::ParseError, /fragment-ladder/)
    end
  end

  describe "the all-parts neighbour keeps parsing" do
    # An all-parts form over a sound fragment: the MEMBER is the fragment
    # the walk reaches (the all-parts wrapper itself has no typed stage).
    # Its render is the pre-existing all-parts face (the member's part is
    # dropped and the render does not re-parse to itself) — pinned as is.
    let(:id) { Pubid::Iec.parse("IEC 60050-191/FRAG1 ED2 (all parts)") }

    it "wraps a base-carrying published fragment" do
      expect(id).to be_a(Pubid::Iec::Identifiers::AllParts)
      member = id.identifiers.first
      expect(member).to be_a(Pubid::Iec::Identifiers::FragmentIdentifier)
      expect(member.base).not_to be_nil
      expect(member.typed_stage.stage_code.to_s).to eq("published")
    end

    it "renders the all-parts face" do
      expect(id.to_s).to eq("IEC 60050/FRAG1 (all parts)")
    end

    it "is == its from_hash(to_hash) round trip" do
      expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end

  describe "the real fragment faces keep parsing byte-identically" do
    # Every attested fragment face: the on-base "/FRAG<n>" notation of the
    # PUBLISHED fragment, over an IS, an amendment or a corrigendum (the
    # FRAGC spelling), with copublishers, dates, editions and multi-digit
    # numbers — plus the wrapper neighbours (a Vap over a sound fragment,
    # the all-parts form). All renders are the main-baseline bytes.
    keep = {
      "IEC 60050-191/AMD1/FRAG1 ED1" => "IEC 60050-191/AMD1/FRAG1 ED1",
      "IEC 60050-191/AMD2/FRAG2 ED1" => "IEC 60050-191/AMD2/FRAG2 ED1",
      "IEC 60050-191/FRAG1 ED2" => "IEC 60050-191/FRAG1 ED2",
      "IEC 60050-191/COR1/FRAGC1" => "IEC 60050-191/COR1/FRAGC1",
      "ISO/IEC 60050-191/AMD1/FRAG1" => "ISO/IEC 60050-191/AMD1/FRAG1",
      "IEC 60050-191:2010/AMD2:2015/FRAG2" =>
        "IEC 60050-191:2010/AMD2:2015/FRAG2",
      "IEC 60050-191/AMD10/FRAG12" => "IEC 60050-191/AMD10/FRAG12",
      "IEC 60038/FRAG1" => "IEC 60038/FRAG1",
      "IEC 60038/FRAG1 CSV" => "IEC 60038 CSV/FRAG1",
    }.freeze

    keep.each do |input, render|
      context input do
        let(:id) { Pubid::Iec.parse(input) }

        it "parses as a FragmentIdentifier with a base" do
          expect(id).to be_a(Pubid::Iec::Identifiers::FragmentIdentifier)
          expect(id.base).not_to be_nil
          expect(id.fragment_number).not_to be_nil
        end

        it "renders #{render.inspect}" do
          expect(id.to_s).to eq(render)
        end

        it "carries the published fragment stage" do
          expect(id.typed_stage.stage_code.to_s).to eq("published")
        end

        it "is == its from_hash(to_hash) round trip" do
          expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
        end

        it "re-parses its own render to the same identifier" do
          expect(Pubid::Iec.parse(id.to_s)).to eq(id)
        end
      end
    end
  end

  describe "a pre-#731 stored hash still deserializes (deliberate residue)" do
    # from_hash is the deserialization path: a hash produced by a pre-#731
    # parse (the shape parsed before the reject) still builds. No published
    # relaton-data-iec row carries the shape — no source prints the face —
    # so nothing stored moves; the built object is the same degenerate
    # fragment it always was. Parse rejects the shape instead, so no NEW
    # hash of this shape can be produced by parsing.
    context "the base-less ladder row (what parse used to produce)" do
      let(:id) do
        stored = {
          "_type" => "pubid:iec:fragment-identifier", "stage" => "dfrag"
        }
        Pubid::Iec::Identifier.from_hash(stored)
      end

      it "builds the base-less fragment" do
        expect(id).to be_a(Pubid::Iec::Identifiers::FragmentIdentifier)
        expect(id.base).to be_nil
      end

      it "carries the stored stage and renders the degenerate face" do
        expect(id.to_hash).to eq(
          "_type" => "pubid:iec:fragment-identifier", "stage" => "dfrag",
        )
        expect(id.to_s).to eq("/FRAG")
      end
    end

    context "the published-token row (stage absent, the attribute default)" do
      let(:id) do
        Pubid::Iec::Identifier.from_hash(
          "_type" => "pubid:iec:fragment-identifier",
        )
      end

      it "builds the base-less published fragment" do
        expect(id).to be_a(Pubid::Iec::Identifiers::FragmentIdentifier)
        expect(id.base).to be_nil
        expect(id.to_s).to eq("/FRAG")
      end
    end

    context "a base-carrying ladder-stage row" do
      let(:id) do
        Pubid::Iec::Identifier.from_hash(
          "_type" => "pubid:iec:fragment-identifier", "stage" => "cdfrag",
          "base" => {
            "_type" => "pubid:iec:international-standard",
            "number" => "60038",
          },
          "fragment_number" => "1"
        )
      end

      it "builds the fragment with its base and stage" do
        expect(id.base.number).to eq("60038")
        expect(id.fragment_number).to eq("1")
        expect(id.typed_stage.code.to_s).to eq("cdfrag")
        # the stage still has no printed face — the render drops it
        expect(id.to_s).to eq("IEC 60038/FRAG1")
      end
    end
  end

  describe "the TYPED_STAGES registry stays queryable" do
    # The reject is a shape check at parse, not a registry removal: the
    # stage rows keep their codes and harmonized stages (metanorma-iec's
    # stage lookups and the URN stage slot resolve through them), so
    # locate_stage still answers every ladder abbreviation.
    it "locates every ladder abbreviation" do
      ["PWI Frag", "NP Frag", "ANW Frag", "WD Frag", "CDFRAG", "DFRAG",
       "FDFRAG", "PRF Frag", "FRAG"].each do |abbr|
        stage = Pubid::Iec.locate_stage(abbr)
        expect(stage).not_to be_nil
        expect(stage.type_code.to_s).to eq("frag")
      end
    end
  end
end
