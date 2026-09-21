# frozen_string_literal: true

require "spec_helper"

# The joint stage-draft conventions defined in docs/IEEE-DRAFT-STAGES.md:
# the D= marker binds a joint draft to its ISO/IEC stage, the compound
# form names both the IEEE ordinal and the stage iteration, and the
# doubled-D spellings are aliases of the canonical form.
RSpec.describe "IEEE joint stage drafts" do
  describe "the canonical compound form" do
    it "parses and renders D5=DIS.3 byte-exactly" do
      id = Pubid::Ieee::Identifier.parse("IEEE P24748-5/D5=DIS.3")
      expect(id.to_s).to eq("IEEE P24748-5/D5=DIS.3")
    end

    it "reads the ordinal and the stage iteration independently" do
      id = Pubid::Ieee::Identifier.parse("IEEE P24748-5/D5=DIS.3")
      expect(id.draft_obj.iso_stage).to eq("DIS")
      expect(id.draft_obj.iso_iteration).to eq("3")
    end
  end

  describe "the doubled-D aliases" do
    it "normalizes =DDIS.3 to =DIS.3" do
      expect(Pubid::Ieee::Identifier.parse("IEEE P24748-5/D5=DDIS.3").to_s)
        .to eq("IEEE P24748-5/D5=DIS.3")
    end

    it "normalizes the glued =DDIS3" do
      expect(Pubid::Ieee::Identifier.parse("IEEE P24748-5/D5=DDIS3").to_s)
        .to eq("IEEE P24748-5/D5=DIS.3")
    end
  end

  describe "the ordinal-less stage draft" do
    it "renders P/NUMBER/D=STAGE:year" do
      expect(Pubid::Ieee::Identifier.parse("IEC/IEEE P63113/D=CDV:2020").to_s)
        .to eq("IEC/IEEE P63113/D=CDV:2020")
    end

    it "renders without a date when none is spelled" do
      expect(Pubid::Ieee::Identifier.parse("IEC/IEEE P63113/D=CDV").to_s)
        .to eq("IEC/IEEE P63113/D=CDV")
    end
  end

  describe "the explicit stage outranks the ordinal ladder" do
    it "types D2=DFDIS as FDIS, not the D2 committee draft" do
      id = Pubid::Ieee::Identifier.parse("IEEE P24748-5/D2=DFDIS.3")
      expect(id.to_hash["stage"]).to eq("FDIS")
    end
  end
end
