# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Etsi::Scheme do
  describe ".new" do
    it "creates a new scheme with type and number" do
      scheme = described_class.new(type: "EN", number: "300 000")
      expect(scheme.type).to eq("EN")
      expect(scheme.number).to eq("300 000")
    end

    it "creates a new scheme with parts" do
      scheme = described_class.new(type: "EN", number: "300 000", part: ["1", "2"])
      expect(scheme.part).to eq(["1", "2"])
    end
  end

  describe "#to_s" do
    it "renders basic identifier" do
      scheme = described_class.new(type: "EN", number: "300 000")
      expect(scheme.to_s).to eq("ETSI EN 300 000")
    end

    it "renders identifier with parts" do
      scheme = described_class.new(type: "EN", number: "300 000", part: ["1"])
      expect(scheme.to_s).to eq("ETSI EN 300 000-1")
    end

    it "renders identifier with amendment" do
      scheme = described_class.new(type: "EN", number: "300 000", amendment: "1")
      expect(scheme.to_s).to eq("ETSI EN 300 000/A1")
    end

    it "renders identifier with corrigendum" do
      scheme = described_class.new(type: "EN", number: "300 000", corrigendum: "1")
      expect(scheme.to_s).to eq("ETSI EN 300 000/C1")
    end

    it "renders identifier with date" do
      scheme = described_class.new(type: "EN", number: "300 000", date: "2000")
      expect(scheme.to_s).to eq("ETSI EN 300 000 (2000)")
    end
  end

  it "is a Lutaml::Model::Serializable class" do
    expect(described_class).to be < Lutaml::Model::Serializable
  end
end
