# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Components::Adoption do
  describe "#present?" do
    it "returns false for an empty adoption" do
      expect(described_class.new).not_to be_present
    end

    it "returns true when adopter_publisher is set" do
      publisher = Pubid::Components::Publisher.new(body: "BS")
      expect(described_class.new(adopter_publisher: publisher)).to be_present
    end

    it "returns true when translation_lang is set" do
      expect(described_class.new(translation_lang: "fr")).to be_present
    end

    it "returns true when reaffirmation_year is set" do
      expect(described_class.new(reaffirmation_year: "2004")).to be_present
    end
  end

  describe "#render" do
    let(:base_id) { Pubid::Iso::Identifier.parse("ISO 8601:2019") }

    it "returns empty string when no base is set" do
      expect(described_class.new.render).to eq("")
    end

    it "renders the base identifier alone by default" do
      adoption = described_class.new(base: base_id)
      expect(adoption.render).to eq("ISO 8601:2019")
    end

    it "appends translation suffix" do
      adoption = described_class.new(
        base: base_id,
        translation_lang: "fr",
        translation_suffix_type: "version",
      )
      expect(adoption.render).to eq("ISO 8601:2019 FRversion")
    end

    it "uses 'Translation' as the default suffix type" do
      adoption = described_class.new(
        base: base_id,
        translation_lang: "fr",
      )
      expect(adoption.render).to eq("ISO 8601:2019 FRTranslation")
    end

    it "appends reaffirmation marker" do
      adoption = described_class.new(
        base: base_id,
        reaffirmation_year: "2004",
      )
      expect(adoption.render).to eq("ISO 8601:2019 (R2004)")
    end

    it "appends commentary marker" do
      adoption = described_class.new(
        base: base_id,
        expert_commentary: true,
        expert_commentary_topic: "Legal",
      )
      expect(adoption.render).to eq("ISO 8601:2019 (Commentary: Legal)")
    end

    it "stacks translation, reaffirmation, and commentary" do
      adoption = described_class.new(
        base: base_id,
        translation_lang: "fr",
        reaffirmation_year: "2004",
        expert_commentary: true,
      )
      expect(adoption.render)
        .to eq("ISO 8601:2019 FRTranslation (R2004) (Commentary)")
    end
  end

  describe "#eql?" do
    let(:base_id) { Pubid::Iso::Identifier.parse("ISO 8601:2019") }

    it "matches another adoption with same fields" do
      a = described_class.new(base: base_id, reaffirmation_year: "2004")
      b = described_class.new(base: base_id, reaffirmation_year: "2004")
      expect(a).to eq(b)
    end

    it "does not match when reaffirmation_year differs" do
      a = described_class.new(base: base_id, reaffirmation_year: "2004")
      b = described_class.new(base: base_id, reaffirmation_year: "2010")
      expect(a).not_to eq(b)
    end
  end

  describe "#hash" do
    it "is stable across equal instances" do
      a = described_class.new(reaffirmation_year: "2004",
                              translation_lang: "fr")
      b = described_class.new(reaffirmation_year: "2004",
                              translation_lang: "fr")
      expect(a.hash).to eq(b.hash)
    end
  end
end
