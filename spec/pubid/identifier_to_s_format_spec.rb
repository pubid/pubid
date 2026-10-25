# frozen_string_literal: true

RSpec.describe "Identifier#to_s format passthrough" do
  # to_s delegates to render with a human-format default; a caller-supplied
  # format must reach render instead of being shadowed by the default.
  it "renders a URN when format: :urn is passed" do
    id = Pubid::Iso::Identifier.parse("ISO 32000-2:2020/DAM 1")

    expect(id.to_s(format: :urn)).to start_with("urn:iso:std:iso:32000")
    expect(id.to_s(format: :urn)).to eq(id.render(format: :urn))
  end

  it "defaults to the human designation" do
    id = Pubid::Iso::Identifier.parse("ISO 32000-2:2020/DAM 1")

    expect(id.to_s).to eq("ISO 32000-2:2020/DAM 1")
  end
end
