# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::SchemeExporter do
  describe "#export" do
    context "ISO flavor" do
      let(:exporter) { described_class.new(:iso) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end

      it "includes International Standard" do
        is_type = result.identifier_types.find { |t| t.key == "is" }
        expect(is_type).not_to be_nil
        expect(is_type.title).to eq("International Standard")
      end

      it "includes typed stages for International Standard" do
        is_type = result.identifier_types.find { |t| t.key == "is" }
        expect(is_type.typed_stages.size).to be > 0
        dis = is_type.typed_stages.find { |ts| ts.stage_code == "dis" }
        expect(dis).not_to be_nil
      end

      it "includes Amendment type" do
        amd = result.identifier_types.find { |t| t.key == "amd" }
        expect(amd).not_to be_nil
      end
    end

    context "IEC flavor" do
      let(:exporter) { described_class.new(:iec) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end
    end

    context "ANSI flavor (no typed stages)" do
      let(:exporter) { described_class.new(:ansi) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has at least one identifier type" do
        expect(result.identifier_types.size).to be >= 1
      end
    end
  end
end
