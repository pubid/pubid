# frozen_string_literal: true

require "spec_helper"

# The ISO-led P follows the document, not the publisher: the project
# marker is identity (docs/IEEE-DRAFT-STAGES.md §1.1), so a P the source
# spells survives on a draft-stage reference too, and the catalogue-
# printed form on a published Std keeps it. relaton's rawbib corpus
# prints both shapes.
RSpec.describe Pubid::Ieee::Identifier do
  describe "the ISO-led joint draft project marker" do
    it "keeps the P when the typed stage is a published Std" do
      id = described_class.parse("IEEE-P15026-3-DIS-January 2015")

      expect(id.typed_stage.stage_code).to eq("published")
      expect(id.to_s).to eq("ISO/IEC/IEEE P15026-3/DDIS January, 2015")
    end

    it "keeps the spelled P when the typed stage marks a draft" do
      id = described_class.parse("ISO/IEC/IEEE P24774/DIS, July 2020")

      expect(id.typed_stage.stage_code).to eq("draft")
      expect(id.project_marker).to be(true)
      expect(id.to_s).to eq("ISO/IEC/IEEE P24774/DDIS, July 2020")
    end
  end
end
