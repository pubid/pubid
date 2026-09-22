# frozen_string_literal: true

require "spec_helper"

# OGC's edition/version discriminator is `revision` ("r19"), which is not in
# the default Identifier.all_parts_edition_keys list (%i[date year edition
# version]). `year` IS in that default list, but for OGC it is the document's
# core "<yy>" identity token (the renderer needs it to print "12-128"), not
# an edition marker, so the override must drop it from the stripped set
# rather than add to it.
RSpec.describe "OGC all parts" do
  describe "#to_all_parts" do
    it "strips the revision but keeps the year/number core" do
      id = Pubid::Ogc::Identifier.parse("12-128r19")
      expect(id.to_all_parts.to_s).to eq("12-128 (all parts)")
    end

    it "renders the same identity with no revision present" do
      id = Pubid::Ogc::Identifier.parse("12-128")
      expect(id.to_all_parts.to_s).to eq("12-128 (all parts)")
    end
  end

  describe "#===" do
    it "matches another revision of the same document" do
      all = Pubid::Ogc::Identifier.parse("12-128r19").to_all_parts
      expect(all === Pubid::Ogc::Identifier.parse("12-128r1")).to be true
      expect(all === Pubid::Ogc::Identifier.parse("12-128")).to be true
    end

    it "does not match a different document number" do
      all = Pubid::Ogc::Identifier.parse("12-128r19").to_all_parts
      expect(all === Pubid::Ogc::Identifier.parse("12-129r19")).to be false
    end

    it "does not match a different year" do
      all = Pubid::Ogc::Identifier.parse("12-128r19").to_all_parts
      expect(all === Pubid::Ogc::Identifier.parse("13-128r19")).to be false
    end
  end
end
