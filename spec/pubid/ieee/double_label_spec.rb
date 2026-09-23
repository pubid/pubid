# frozen_string_literal: true

require "spec_helper"

# The user rulings on the rawbib forms (2026-09-22): a glued-WD draft is
# a stage-draft of an ISO/IEC stage ("WD5" = the WD stage, iteration 5 —
# the "201x" placeholder year is replaced by the real year), and the
# "…(E) ANSI/IEEE Std …" spelling is a DOUBLE-LABELED standard carrying
# an ISO/IEC label and an IEEE label for one document.
RSpec.describe Pubid::Ieee::Identifier do
  describe "the glued-WD stage draft" do
    it "normalizes to the stage-draft form with the real year" do
      id = described_class.parse("ISO/IEC/IEEE P16326:201x WD5, December 2017")

      expect(id).to be_a(Pubid::Ieee::Identifiers::JointDevelopment)
      expect(id.to_s).to eq("ISO/IEC/IEEE P16326:2017/D=WD.5")
      expect(id.ieee_draft).to eq("D=WD.5")
    end

    it "keeps the lettered iteration" do
      id = described_class.parse("ISO/IEC/IEEE P16326:201x WD.4a, July 2017")

      expect(id.to_s).to eq("ISO/IEC/IEEE P16326:2017/D=WD.4a")
    end
  end

  describe "the double-labeled standard" do
    it "carries the dash-part label of the 8802 family" do
      id = described_class.parse(
        "International Standard ISO/IEC 8802-9: 1996(E) ANSI/IEEE Std 802.9, 1996 Edition",
      )

      expect(id).to be_a(Pubid::Ieee::Identifiers::DualPublished)
      expect(id.to_s).to eq("ISO/IEC 8802-9:1996 (E) and ANSI/IEEE 802.9-1996")
      expect(id.first_identifier.to_s).to eq("ISO/IEC 8802-9:1996 (E)")
      expect(id.second_identifier.to_s).to eq("ANSI/IEEE 802.9-1996")
    end

    it "carries the ISO/IEC label and the IEEE label as one document" do
      id = described_class.parse("ISO/IEC13210: 1994 (E) ANSI/IEEE Std 1003.3-1991")

      expect(id).to be_a(Pubid::Ieee::Identifiers::DualPublished)
      expect(id.first_identifier).to be_a(Pubid::Ieee::Identifiers::JointDevelopment)
      expect(id.first_identifier.to_s).to eq("ISO/IEC 13210:1994 (E)")
      expect(id.second_identifier).to be_a(Pubid::Ieee::Identifiers::Standard)
      expect(id.second_identifier.to_s).to eq("ANSI/IEEE 1003.3-1991")
      expect(id.to_s).to eq("ISO/IEC 13210:1994 (E) and ANSI/IEEE 1003.3-1991")
    end
  end
end
