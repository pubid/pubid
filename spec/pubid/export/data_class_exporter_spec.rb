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

      it "includes ETSI Standard type" do
        en = result.identifier_types.find { |t| t.key == "etsi_standard" }
        expect(en).not_to be_nil
      end

      it "includes Supplement type" do
        ts = result.identifier_types.find { |t| t.key == "supplement_identifier" }
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
