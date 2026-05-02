# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::ItuExporter do
  describe "#export" do
    let(:exporter) { described_class.new(:itu) }
    let(:result) { exporter.export }

    it "returns a FlavorResult" do
      expect(result).to be_a(Pubid::Export::FlavorResult)
    end

    it "has identifier types" do
      expect(result.identifier_types.size).to be > 0
    end

    it "includes recommendation type" do
      rec = result.identifier_types.find { |t| t.key == "recommendation" }
      expect(rec).not_to be_nil
    end
  end
end
