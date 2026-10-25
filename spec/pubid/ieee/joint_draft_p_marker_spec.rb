# frozen_string_literal: true

require "spec_helper"

# pubid#597, the owner's ruling: a joint row carrying a numeric /D
# designator is a draft whatever the lead publisher, and its canonical
# face is BOTH — the word Draft and the P before the project number —
# even when the source spelling carried neither.
RSpec.describe "IEEE joint draft faces with the P marker (pubid#597)" do
  let(:ieee) { (Pubid.eager_load_flavors!; Pubid::Registry.get("ieee")) }

  it "renders the ISO/IEEE row as a Draft with the P prepended" do
    id = ieee.parse("ISO/IEEE 11073-20601a/D31, Aug 2010")
    expect(id).to be_a(Pubid::Ieee::Identifiers::ProjectDraftIdentifier)
    expect(id.project_marker).to be(true)
    face = id.to_s
    expect(face).to eq("ISO/IEEE Draft P11073-20601a/D31, Aug 2010")
    expect(ieee.parse(face)).to eq(id)
  end

  it "keeps the P on rows whose source already spelled it" do
    id = ieee.parse("IEEE/IEC Draft P60079-30-1/D5, Jan, 2022")
    expect(id.project_marker).to be(true)
    expect(id.to_s).to eq("IEEE/IEC Draft P60079-30-1/D5, Jan, 2022")
  end

  it "does not disturb the printed-joint rows without a draft" do
    id = ieee.parse("ISO/IEC/IEEE 8802-3:2021")
    expect(id.to_s).to eq("ISO/IEC/IEEE 8802-3:2021")
  end
end
