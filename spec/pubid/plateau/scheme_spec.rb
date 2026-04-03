# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Plateau::Scheme do
  describe ".new" do
    it "creates a new scheme with type and number" do
      scheme = described_class.new(type: "Handbook", number: 1)
      expect(scheme.type).to eq("Handbook")
      expect(scheme.number).to eq(1)
    end

    it "creates a new scheme with annex" do
      scheme = described_class.new(type: "Handbook", number: 1, annex: 1)
      expect(scheme.annex).to eq(1)
    end

    it "creates a new scheme with edition" do
      scheme = described_class.new(type: "Handbook", number: 1, edition: "1")
      expect(scheme.edition).to eq("1")
    end
  end

  describe "#to_s" do
    it "renders basic handbook identifier" do
      scheme = described_class.new(type: "Handbook", number: 1)
      expect(scheme.to_s).to eq("PLATEAU Handbook #01")
    end

    it "renders technical report identifier" do
      scheme = described_class.new(type: "Technical Report", number: 5)
      expect(scheme.to_s).to eq("PLATEAU Technical Report #05")
    end

    it "renders identifier with annex" do
      scheme = described_class.new(type: "Handbook", number: 1, annex: 2)
      expect(scheme.to_s).to eq("PLATEAU Handbook #01-2")
    end

    it "renders identifier with edition" do
      scheme = described_class.new(type: "Handbook", number: 1, edition: "2")
      expect(scheme.to_s).to eq("PLATEAU Handbook #01 第2版")
    end
  end

  it "is a Lutaml::Model::Serializable class" do
    expect(described_class).to be < Lutaml::Model::Serializable
  end
end
