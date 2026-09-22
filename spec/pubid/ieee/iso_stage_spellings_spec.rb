# frozen_string: true

require "spec_helper"

# pubid#216 residuals: mechanical spellings of the joint ISO-stage forms
# that no grammar branch reached. Recovered by a grammar tail (a text date
# may trail the draft; a spaced (E) and a relationship parenthetical may
# follow) plus Parser.normalize_joint_stage_spellings, which rewrites only
# BROKEN separators (underscore/space glue, slash-space, dash-month) into
# the spelling joint_development_iso_format accepts. The semantic residue
# (ED stages, "Second edition", amendment+stage, YYMM date codes) stays
# deferred.
# P = project (the document is a draft), so the recovered forms KEEP the
# project marker — the earlier P-less pins predate the P-state ruling
# (docs/IEEE-DRAFT-STAGES.md §1.1).
RSpec.describe "IEEE joint ISO-stage spellings — issue #216" do
  subject(:klass) { Pubid::Ieee::Identifier }

  def next_render(str)
    klass.parse(str).to_s
  rescue StandardError
    str
  end

  def converged(input)
    out = klass.parse(input).to_s
    4.times { out = next_render(out) }
    out
  end

  {
    # grammar tail: text date after the draft, stage-first
    "ISO/IEC/IEEE CD P26515/D1, March 2017" => "ISO/IEC/IEEE CD P26515:2017",
    "ISO/IEC/IEEE/FDIS P24748-2/D3, June 2018" =>
      "ISO/IEC/IEEE FDIS P24748.2:2018",
    # grammar tail: bare comma-year after the draft
    "ISO/IEC/IEEE FDIS P15289_D3, 2017" => "ISO/IEC/IEEE FDIS P15289:2017",
    # underscore stage after the draft
    "ISO/IEC/IEEE P24748-3/D3_FDIS, April 2020 (E)" =>
      "ISO/IEC/IEEE FDIS P24748.3:2020 (E)",
    # underscore draft, then underscore stage
    "ISO/IEC/IEEE P24641_D2_CD, June 2020" => "ISO/IEC/IEEE CD P24641:2020",
    # comma with no space before the month
    "ISO/IEC/IEEE P24641_D3_CD2,March 2021" => "ISO/IEC/IEEE CD P24641:2021",
    # slash-SPACE before the stage
    "ISO/IEC/IEEE P16085/ FDIS, August 2020" =>
      "ISO/IEC/IEEE FDIS P16085:2020",
    # space-year after a slash-stage
    "ISO/IEC/IEEE P26511.2_FDIS 2018" => "ISO/IEC/IEEE FDIS P26511.2:2018",
    # space-separated stage after the number
    "IEC/IEEE P63113 CD4, April 2019" => "IEC/IEEE CD P63113:2019",
    "IEC/IEEE P63113 CDV, May 2020" => "IEC/IEEE CDV P63113:2020",
    # chained space-stage + space-draft
    "IEC/IEEE P60980-344 CDV D1, June2019" =>
      "IEC/IEEE CDV P60980.344:2019",
    # space-draft after a stage-first number
    "ISO/IEEE DIS P11073-10418 D13, January 2011" =>
      "ISO/IEEE DIS P11073.10418:2011",
    # slash-stage carrying a dash-date, plus a relationship parenthetical
    "ISO/IEC/IEEE P15288/CD2-2013-09 (Revision of ISO/IEC/IEEE 15288:2008)" =>
      "ISO/IEC/IEEE CD P15288:2013",
  }.each do |input, expected|
    context input.inspect do
      it "converges to #{expected.inspect}" do
        expect(converged(input)).to eq(expected)
      end

      it "parses and reaches a rendering fixed point" do
        out = converged(input)
        expect(next_render(out)).to eq(out)
      end

      it "round-trips the converged identifier through to_hash/from_hash" do
        hash = klass.parse(converged(input)).to_hash
        expect(klass.from_hash(hash).to_hash).to eq(hash)
      end

      it "keeps the stage in the converged hash" do
        hash = klass.parse(converged(input)).to_hash
        expect(hash["iso_stage"] || hash["stage"])
          .to match(/\A(FDIS|FCD|CDV|DIS|CD|WD|PWI|NP)/)
      end
    end
  end

  it "does not steal spellings ieee_p_identifier already parses" do
    # A plain "/FDIS" tail (no broken separator) keeps its original route:
    # the multi-part number "62271-37-013" is beyond the joint rule's
    # single-part grammar, and the comma-date is natively accepted.
    id = klass.parse("IEC/IEEE P62271-37-013/FDIS, June 2021")
    expect(id.to_s).to include("62271")
  end
end
