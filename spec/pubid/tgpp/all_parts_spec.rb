# frozen_string_literal: true

require "spec_helper"

# 3GPP's edition/version identity is split across `release` and `version`.
# `version` is already in the default Identifier.all_parts_edition_keys list
# (%i[date year edition version]); `release` is not, so it survived
# without_parts untouched and leaked into the all-parts identity.
RSpec.describe "3GPP all parts" do
  describe "#to_all_parts" do
    it "strips both the release and the version" do
      id = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207:REL-4/4.0.0")
      expect(id.to_all_parts.to_s).to eq("TS 23.207 (all parts)")
    end

    it "renders the same identity with neither qualifier present" do
      id = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207")
      expect(id.to_all_parts.to_s).to eq("TS 23.207 (all parts)")
    end
  end

  describe "#===" do
    it "matches another release of the same document" do
      all = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207:REL-4/4.0.0")
        .to_all_parts
      other = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207:REL-5/5.0.0")
      expect(all === other).to be true
    end

    it "matches another version of the same release" do
      all = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207:REL-4/4.0.0")
        .to_all_parts
      other = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207:REL-4/4.1.0")
      expect(all === other).to be true
    end

    it "does not match a different document number" do
      all = Pubid::Tgpp::Identifier.parse("3GPP TS 23.207:REL-4/4.0.0")
        .to_all_parts
      other = Pubid::Tgpp::Identifier.parse("3GPP TS 23.208:REL-4/4.0.0")
      expect(all === other).to be false
    end
  end
end
