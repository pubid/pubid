# frozen_string_literal: true

require "spec_helper"
require "pubid"
require "pubid/gost"

RSpec.describe Pubid::TypeResolver do
  describe ".resolve" do
    it "returns nil for nil" do
      expect(described_class.resolve(nil)).to be_nil
    end

    it "returns nil for a non-string" do
      expect(described_class.resolve(Object.new)).to be_nil
    end

    it "returns nil when the type has no pubid: prefix" do
      expect(described_class.resolve("iso:technical-report")).to be_nil
    end

    it "returns nil when the type has no flavor segment" do
      expect(described_class.resolve("pubid:")).to be_nil
    end

    it "returns nil when the flavor is not registered" do
      expect(described_class.resolve("pubid:unknown-flavor:thing")).to be_nil
    end

    it "returns nil when the type is unknown to its own flavor" do
      expect(described_class.resolve("pubid:iso:not-a-real-type")).to be_nil
    end

    it "resolves an ISO _type to the concrete class" do
      resolved = described_class.resolve("pubid:iso:technical-report")
      expect(resolved).to eq(Pubid::Iso::Identifiers::TechnicalReport)
    end

    it "resolves a GOST _type to the concrete class" do
      resolved = described_class.resolve("pubid:gost:harmonized")
      expect(resolved).to eq(Pubid::Gost::Identifiers::Harmonized)
    end

    it "eager-loads flavors before lookup so Registry is populated" do
      # In a fresh process, only loaded flavors appear in Registry. The
      # resolver must trigger autoload so any registered flavor can serve
      # its map — without this, a nested adopted ISO identifier inside a
      # GOST Harmonized would never resolve.
      expect(Pubid::Registry).to receive(:get).with("iso").and_call_original
      described_class.resolve("pubid:iso:technical-report")
    end
  end
end
