# frozen_string_literal: true

require "spec_helper"

# The IEC consolidated peel is recursive (the BSI/CSA/CEN shape): a
# consolidated edition of a supplement reduces to its origin standard,
# not to the first member's own layer (pubid#580's base_document
# doctrine — the peel is what a dated base query resolves through).
RSpec.describe "IEC ConsolidatedIdentifier base_document peel" do
  let(:iec) { (Pubid.eager_load_flavors!; Pubid::Registry.get("iec")) }

  it "peels a consolidated edition of a supplement to the origin standard" do
    c = iec.parse("IEC 60050-300:2001+AMD1:2005 CSV")
    expect(c.base_document.to_s).to eq("IEC 60050-300:2001")
    expect(c.base_document).not_to respond_to(:identifiers)
  end

  it "answers wrapped_edition_of? for the wrapped record of a named edition" do
    c = iec.parse("IEC 60050-300:2001+AMD1:2005 CSV")
    expect(c).to be_wrapped_edition_of(iec.parse("IEC 60050-300:2001"))
    expect(c).not_to be_wrapped_edition_of(iec.parse("IEC 60050-300"))
  end
end
