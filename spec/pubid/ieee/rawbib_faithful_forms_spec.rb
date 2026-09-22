# frozen_string_literal: true

require "spec_helper"

# The rawbib joint-draft spellings parse to the same faithful
# classification as their slash siblings: the project P survives, the
# draft rides the draft clause, and the text date stays with it
# (pubid#430). A colon-year joint reference whose "IEEE Std" tail cites
# a different-number standard stays a colon-year JointDevelopment —
# the tail is a citation, not the identifier's stage (pubid#427).
RSpec.describe Pubid::Ieee::Identifier do
  describe "the underscore joint drafts (pubid#430)" do
    it "parses the underscore D-draft as the project draft its sibling pins" do
      id = described_class.parse("ISO /IEC/IEEE P24774_D1, February 2020")

      expect(id).to be_a(Pubid::Ieee::Identifiers::ProjectDraftIdentifier)
      expect(id.to_s).to eq("ISO/IEC/IEEE P24774/D1, February, 2020")
      expect(id.project_marker).to be(true)
    end

    it "keeps the draft numeral and the text date together" do
      id = described_class.parse("ISO /IEC/IEEE P24774_D3, January 2021")

      expect(id.to_s).to eq("ISO/IEC/IEEE P24774/D3, January, 2021")
    end

  end

end
