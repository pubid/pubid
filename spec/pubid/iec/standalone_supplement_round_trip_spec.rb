# frozen_string_literal: true

# A supplement written in the LEGACY PREFIX FACE ("IEC/FDAM 60038-1",
# "IEC/DCOR 60038-1") names the document it supplements after the stage
# token. It DECODES onto the modern identity (owner ruling 2026-11-12,
# reversing #693): the whole designation moves onto a concrete
# InternationalStandard base, the supplement keeps a number of its own
# defaulting to 1 (the no-number rule), and the date rides with the
# designation — so the legacy face and the modern on-base form are the
# SAME identifier, byte for byte, hash for hash.
#
# The TRUE standalone ("IEC/AMD 1:2017" — a bare ordinal, no base
# designation) keeps the synthetic self-base: base number == supplement
# number, standalone render.
RSpec.describe "IEC legacy standalone supplement decode" do
  legacy_faces = {
    "IEC/FDAM 60038-1" => ["IEC 60038-1/FDAM 1", Pubid::Iec::Identifiers::Amendment],
    "IEC FDAM 60038-1" => ["IEC 60038-1/FDAM 1", Pubid::Iec::Identifiers::Amendment],
    "IEC/DCOR 60038-1" => ["IEC 60038-1/DCOR 1", Pubid::Iec::Identifiers::Corrigendum],
    "IEC/DISH 60038-1" => ["IEC 60038-1/DISH 1", Pubid::Iec::Identifiers::InterpretationSheet],
    # Subpart and date ride with the designation, onto the base.
    "IEC/FDAM 60038-1-2:2020" => ["IEC 60038-1-2:2020/FDAM 1", Pubid::Iec::Identifiers::Amendment],
    "IEC DISH 60038-1:2020" => ["IEC 60038-1:2020/DISH 1", Pubid::Iec::Identifiers::InterpretationSheet],
    "IEC DCOR 60038-1:2019" => ["IEC 60038-1:2019/DCOR 1", Pubid::Iec::Identifiers::Corrigendum],
  }.freeze

  legacy_faces.each do |input, (modern, klass)|
    context input do
      let(:id) { Pubid::Iec.parse(input) }
      let(:modern_id) { Pubid::Iec.parse(modern) }
      let(:back) { Pubid::Iec::Identifier.from_hash(id.to_hash) }

      it "parses to #{klass.name.split('::').last} on a concrete base" do
        expect(id).to be_a(klass)
        expect(id.synthetic_base?).to be false
        expect(id.base).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
      end

      # The decode lands on the modern identity: same object as the
      # modern on-base parse of the same document.
      it "equals the modern on-base parse" do
        expect(id).to eq(modern_id)
        expect(id.to_hash).to eq(modern_id.to_hash)
        expect(id.to_s).to eq(modern_id.to_s)
      end

      # Both halves together: an equal pair must share a hash, and the pair
      # must actually be equal, so the two can never diverge again.
      it "is == and hash-equal to its from_hash(to_hash) round trip" do
        expect(back).to eq(id)
        expect(back.hash).to eq(id.hash)
      end

      it "matches its round trip, also with the year ignored" do
        expect(id.matches?(back)).to be true
        expect(id.matches?(back, ignore: [:year])).to be true
      end

      it "renders and serializes the same on both paths" do
        expect(back.to_s).to eq(id.to_s)
        expect(back.to_urn.to_s).to eq(id.to_urn.to_s)
        expect(back.to_hash).to eq(id.to_hash)
      end

      # The supplement's number is the no-number default; the designation
      # lives whole on the base.
      it "stores the designation on the base and 1 on the supplement" do
        expect(id.number).to eq("1")
        expect(id.base.number).to eq("60038")
        expect(id.base.part).to eq("1")
        expect(id.base.subpart).to eq(input.include?("-2") ? "2" : nil)
      end

      # The modern on-base slash face is the canonical output of the decode,
      # and the render is a fixed point.
      it "renders the modern face and is a render fixed point" do
        rendered = id.to_s
        expect(rendered).to eq(modern_id.to_s)
        expect(Pubid::Iec.parse(rendered).to_s).to eq(rendered)
      end

      # #exclude copies through the readers; the decoded layout must
      # survive it in the attached form.
      it "keeps the attached form after #exclude" do
        excluded = id.exclude(:year)
        expect(excluded.synthetic_base?).to be false
        expect(excluded.to_s).to include("/")
        expect(excluded).to eq(modern_id.exclude(:year))
      end

      # Each reader is asked of a FRESH parse, first: the answer must not
      # depend on which reader happened to run first.
      it "gives the same answers whichever reader runs first" do
        rendered = Pubid::Iec.parse(input).tap(&:to_s)

        expect(Pubid::Iec.parse(input).number).to eq(rendered.number)
        expect(Pubid::Iec.parse(input).base.number).to eq(rendered.base.number)
        expect(Pubid::Iec.parse(input).to_mr_string)
          .to eq(rendered.to_mr_string)
        expect(Pubid::Iec.parse(input).exclude(:date).to_s)
          .to eq(rendered.exclude(:date).to_s)
        expect(Pubid::Iec.parse(input).exclude(:date).to_hash)
          .to eq(rendered.exclude(:date).to_hash)
        expect(rendered.matches?(Pubid::Iec.parse(input), ignore: [:date]))
          .to be true
      end
    end
  end

  # The DAM-family prefix faces reach the grammar's legacy rule; the
  # corrigendum and interpretation-sheet faces reach the standalone and
  # typed branches and are corrected by #ensure_base. Both paths land on
  # the same decode shape — and each face keeps its own draft stage
  # (FDAM is a final-draft amendment, DAM a draft amendment).
  it "decodes the DAM-family faces through the grammar's legacy rule" do
    slash = Pubid::Iec.parse("IEC/FDAM 60038-1")
    space = Pubid::Iec.parse("IEC FDAM 60038-1")
    dam = Pubid::Iec.parse("IEC DAM 60038-1")

    expect(slash).to eq(space)
    expect(slash.to_hash).to eq(dam.to_hash.merge("stage" => "fdamd"))
    expect(dam.stage.stage_code).to eq("damd")
    expect(dam.to_s).to eq("IEC 60038-1/DAM 1")
  end

  it "decodes a bare designation as the base, numbering the supplement 1" do
    id = Pubid::Iec.parse("IEC FDAM 60038")

    expect(id.base.number).to eq("60038")
    expect(id.base.part).to be_nil
    expect(id.number).to eq("1")
    expect(id.to_s).to eq("IEC 60038/FDAM 1")
  end

  # The supplement's own date moves with the designation: old notation
  # prints the base's year, and a draft supplement carries none of its own.
  it "puts the legacy face's date on the base, not on the supplement" do
    id = Pubid::Iec.parse("IEC DCOR 60038-1:2019")

    expect(id.base.date.year).to eq("2019")
    expect(id.date).to be_nil
    expect(id.to_s).to eq("IEC 60038-1:2019/DCOR 1")
  end

  it "stores the supplement number in number and the designation on base" do
    id = Pubid::Iec.parse("IEC/FDAM 60038-1")

    expect(id.instance_variable_get(:@number)).to eq("1")
    expect(id.instance_variable_get(:@part)).to be_nil
    expect(id.base.number).to eq("60038")
    expect(id.base.part).to eq("1")
    expect(id.to_s).to eq("IEC 60038-1/FDAM 1")
  end

  # The TRUE standalone keeps the synthetic self-base: no base designation
  # follows the token, so the bare ordinal is the supplement's own number.
  describe "the self-base standalone" do
    ["IEC/AMD 1:2017"].each do |input|
      context input do
        let(:id) { Pubid::Iec.parse(input) }
        let(:back) { Pubid::Iec::Identifier.from_hash(id.to_hash) }

        it "keeps a synthetic self-base" do
          expect(id).to be_a(Pubid::Iec::Identifiers::Amendment)
          expect(id.synthetic_base?).to be true
          expect(back.synthetic_base?).to be true
          expect(back).to eq(id)
          expect(back.hash).to eq(id.hash)
        end

        it "keeps the standalone form after #exclude" do
          excluded = id.exclude(:year)
          expect(excluded.synthetic_base?).to be true
          expect(excluded.to_s).not_to include("/")
        end
      end
    end
  end

  it "leaves an attached supplement's base alone" do
    id = Pubid::Iec.parse("IEC 60038-1/AMD1:2005")

    expect(id.synthetic_base?).to be false
    expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
  end
end
