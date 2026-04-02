# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/pubid_new/ieee/components/typed_stage"
require_relative "../../../../lib/pubid_new/ieee/typed_stages"
require_relative "../../../../lib/pubid_new/ieee/scheme"

RSpec.describe PubidNew::Ieee::Components::TypedStage do
  describe "TypedStage component" do
    let(:published_stage) do
      described_class.new(
        abbr: ["Std"],
        stage_code: "published",
        type_code: "standard",
        approval_status: "published",
        project_status: false,
      )
    end

    let(:draft_stage) do
      described_class.new(
        abbr: ["D5"],
        stage_code: "draft_standard",
        type_code: "draft",
        ieee_draft_equivalent: "D4-D6",
        iso_stage_equivalent: "DIS",
        approval_status: "unapproved",
        project_status: true,
      )
    end

    let(:iso_stage) do
      described_class.new(
        abbr: ["FDIS"],
        stage_code: "final_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D8",
        iso_stage_equivalent: "FDIS",
        approval_status: "approved",
        project_status: true,
      )
    end

    describe "#canonical_abbreviation" do
      it "returns first abbreviation" do
        expect(published_stage.canonical_abbreviation).to eq("Std")
        expect(draft_stage.canonical_abbreviation).to eq("D5")
      end
    end

    describe "#draft?" do
      it "returns true for draft stages" do
        expect(draft_stage.draft?).to be true
        expect(iso_stage.draft?).to be true
      end

      it "returns false for published stages" do
        expect(published_stage.draft?).to be false
      end
    end

    describe "#approved?" do
      it "returns true for approved or published stages" do
        expect(iso_stage.approved?).to be true
        expect(published_stage.approved?).to be true
      end

      it "returns false for unapproved stages" do
        expect(draft_stage.approved?).to be false
      end
    end

    describe "#to_ieee_format" do
      it "returns canonical abbreviation for published" do
        expect(published_stage.to_ieee_format).to eq("Std")
      end

      it "returns IEEE draft equivalent for drafts" do
        expect(draft_stage.to_ieee_format).to eq("D4-D6")
      end
    end

    describe "#to_iso_format" do
      it "returns canonical abbreviation for published" do
        expect(published_stage.to_iso_format).to eq("Std")
      end

      it "returns ISO stage equivalent when available" do
        expect(draft_stage.to_iso_format).to eq("DIS")
        expect(iso_stage.to_iso_format).to eq("FDIS")
      end
    end

    describe "#name" do
      it "returns human-readable stage name" do
        expect(published_stage.name).to eq("Published Standard")
        expect(draft_stage.name).to eq("Draft Standard")
        expect(iso_stage.name).to eq("Final Draft")
      end
    end
  end

  describe "TYPED_STAGES registry" do
    it "includes published standard" do
      std = PubidNew::Ieee::TYPED_STAGES.find { |ts| ts.abbr.include?("Std") }
      expect(std).not_to be_nil
      expect(std.type_code).to eq("standard")
      expect(std.stage_code).to eq("published")
    end

    it "includes IEEE draft stages D1-D9" do
      d1 = PubidNew::Ieee::TYPED_STAGES.find { |ts| ts.abbr.include?("D1") }
      expect(d1).not_to be_nil
      expect(d1.project_status).to be true

      d5 = PubidNew::Ieee::TYPED_STAGES.find { |ts| ts.abbr.include?("D5") }
      expect(d5).not_to be_nil
      expect(d5.ieee_draft_equivalent).to eq("D4-D6")
    end

    it "includes ISO stages for joint development" do
      fdis = PubidNew::Ieee::TYPED_STAGES.find { |ts| ts.abbr.include?("FDIS") }
      expect(fdis).not_to be_nil
      expect(fdis.iso_stage_equivalent).to eq("FDIS")
      expect(fdis.ieee_draft_equivalent).to eq("D8")
    end

    it "includes historical stages" do
      no = PubidNew::Ieee::TYPED_STAGES.find { |ts| ts.abbr.include?("No") }
      expect(no).not_to be_nil
      expect(no.stage_code).to eq("published")
    end

    it "has default typed stage" do
      expect(PubidNew::Ieee::DEFAULT_TYPED_STAGE).not_to be_nil
      expect(PubidNew::Ieee::DEFAULT_TYPED_STAGE.abbr).to include("Std")
    end
  end

  describe "Scheme class" do
    describe ".locate_typed_stage_by_abbr" do
      it "finds stage by abbreviation" do
        ts = PubidNew::Ieee::Scheme.locate_typed_stage_by_abbr("D5")
        expect(ts.abbr).to include("D5")
      end

      it "returns default for empty abbreviation" do
        ts = PubidNew::Ieee::Scheme.locate_typed_stage_by_abbr("")
        expect(ts).to eq(PubidNew::Ieee::DEFAULT_TYPED_STAGE)
      end
    end

    describe ".locate_typed_stage_by_ieee_draft" do
      it "finds stage by IEEE draft notation" do
        ts = PubidNew::Ieee::Scheme.locate_typed_stage_by_ieee_draft("D1")
        expect(ts.abbr).to include("D1")
      end
    end

    describe ".locate_typed_stage_by_iso_stage" do
      it "finds stage by ISO stage code" do
        ts = PubidNew::Ieee::Scheme.locate_typed_stage_by_iso_stage("FDIS")
        expect(ts.iso_stage_equivalent).to eq("FDIS")
      end
    end
  end
end
