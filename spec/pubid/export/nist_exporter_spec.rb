# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::NistExporter do
  describe "#export" do
    let(:exporter) { described_class.new(:nist) }
    let(:result) { exporter.export }

    it "returns a FlavorResult" do
      expect(result).to be_a(Pubid::Export::FlavorResult)
    end

    it "has identifier types" do
      expect(result.identifier_types.size).to be > 0
    end

    it "does not include the Base class" do
      base = result.identifier_types.find { |t| t.key == "base" }
      expect(base).to be_nil
    end

    it "includes at least 15 identifier types" do
      expect(result.identifier_types.size).to be >= 15
    end
  end
end
