# frozen_string_literal: true

require "spec_helper"

# The guide's resource-specific-id numbering for BIPM documents
# (bipm-editor-guides `partnumbers` proposal, backed by bipm-si-brochure#301):
#
#   Part:     {identifier}-{part}          CIPM DECN 111-10
#   Subpart:  {identifier}-{part}-{subpart} CIPM DECN 111-10-2
#   Appendix: {identifier} A{appendix}      CIPM DECN 112 A3
#   Annex:    {identifier} A{appendix}.{annex} CIPM DECN 112 A3.5
#
# Parts and subparts are dash forms INSIDE `number` and always parsed; the
# appendix/annex complement is the separate ` A{appendix}[.{annex}]` tail,
# stored in the shared `appendix`/`annex` attributes (the MEP/guide tail's
# home) and printed back by the renderer, so these are BYTE round trips.
module BipmPartSpec
  FORMS = [
    "CIPM DECN 111 (2022, F)",
    "CIPM DECN 111-10 (2022, F)",
    "CIPM DECN 111-10-2 (2022, F)",
    "CIPM DECN 112 A3 (2022, F)",
    "CIPM DECN 112 A3.5 (2022, F)",
  ].freeze
end

RSpec.describe "Pubid::Bipm part-numbered committee documents" do
  BipmPartSpec::FORMS.each do |ref|
    context ref.inspect do
      subject(:id) { Pubid::Bipm.parse(ref) }

      it "round-trips byte-exactly" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        expect(Pubid::Bipm::Identifier.from_hash(hash).to_hash).to eq(hash)
      end

      it "keys on the bare number" do
        expect(id.root.number).to eq(ref.split[2])
      end
    end
  end

  it "splits the appendix and the annex into their own attributes" do
    plain = Pubid::Bipm.parse("CIPM DECN 112 A3 (2022, F)")
    expect(plain.appendix).to eq("3")
    expect(plain.annex).to be_nil

    annexed = Pubid::Bipm.parse("CIPM DECN 112 A3.5 (2022, F)")
    expect(annexed.appendix).to eq("3")
    expect(annexed.annex).to eq("5")
  end

  # Separately published subresources are distinct documents, so — like the
  # language — the complement tail has to reach the MR slug.
  it "gives the complement its own MR slug" do
    base = Pubid::Bipm.parse("CIPM DECN 112 (2022, F)").to_mr_string
    app = Pubid::Bipm.parse("CIPM DECN 112 A3 (2022, F)").to_mr_string
    annex = Pubid::Bipm.parse("CIPM DECN 112 A3.5 (2022, F)").to_mr_string

    expect([base, app, annex].uniq.size).to eq(3)
    expect(app).to include("cipm-112-a3.")
    expect(annex).to include("cipm-112-a3-5.") # mr_slug collapses the annex dot
    expect(app).to match(/\A[a-z0-9._-]+\z/)
  end

  # The tail is a parsed complement, not free text: the grammar demands a
  # number before it.
  it "does not accept a complement without a number" do
    expect { Pubid::Bipm.parse("CIPM DECN A3 (2022, F)") }
      .to raise_error(Pubid::Errors::ParseError)
  end
end
