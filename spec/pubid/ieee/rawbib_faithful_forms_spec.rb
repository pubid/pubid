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

    it "parses the glued WD draft as a project draft with the D-stage form" do
      id = described_class.parse("ISO/IEC/IEEE P16326:201x WD5, December 2017")

      expect(id).to be_a(Pubid::Ieee::Identifiers::ProjectDraftIdentifier)
      expect(id.to_s).to eq("ISO/IEC/IEEE P16326/DWD5, December, 2017")
    end

    it "parses the dotted WD draft with its iteration letter" do
      id = described_class.parse("ISO/IEC/IEEE P16326:201x WD.4a, July 2017")

      expect(id.to_s).to eq("ISO/IEC/IEEE P16326/DWD4a, July 2017")
    end
  end

  describe "the colon-year joint reference with a citing tail (pubid#427)" do
    it "keeps the JointDevelopment colon-year print" do
      id = described_class.parse("ISO/IEC13210: 1994 (E) ANSI/IEEE Std 1003.3-1991")

      expect(id).to be_a(Pubid::Ieee::Identifiers::JointDevelopment)
      expect(id.to_s).to eq("ISO/IEC/IEEE 13210:1994")
    end

    it "keeps the restated-number row a published Standard" do
      id = described_class.parse(
        "International Standard ISO/IEC 8802-9: 1996(E) ANSI/IEEE Std 802.9, 1996 Edition",
      )

      expect(id.to_s).to eq("ISO/IEC/IEEE 802.9-1996")
    end
  end
end
