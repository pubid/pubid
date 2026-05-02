# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::DataClassExporter do
  describe "#export" do
    context "ETSI flavor" do
      let(:exporter) { described_class.new(:etsi) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end

      it "includes EN type" do
        en = result.identifier_types.find { |t| t.key == "en" }
        expect(en).not_to be_nil
      end

      it "includes TS type" do
        ts = result.identifier_types.find { |t| t.key == "ts" }
        expect(ts).not_to be_nil
      end
    end

    context "Plateau flavor" do
      let(:exporter) { described_class.new(:plateau) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end
    end
  end
end
