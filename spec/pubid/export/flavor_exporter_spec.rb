# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::FlavorExporter do
  describe "#export" do
    context "NIST flavor" do
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

    context "BSI flavor" do
      let(:exporter) { described_class.new(:bsi) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end
    end

    context "CEN-CENELEC flavor" do
      let(:exporter) { described_class.new(:cen_cenelec) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end
    end

    context "ISO flavor" do
      let(:exporter) { described_class.new(:iso) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types with typed stages" do
        is_type = result.identifier_types.find { |t| t.key == "international_standard" }
        expect(is_type).not_to be_nil
        expect(is_type.typed_stages.size).to be > 0
      end
    end

    context "IEEE flavor" do
      let(:exporter) { described_class.new(:ieee) }
      let(:result) { exporter.export }

      it "returns a FlavorResult" do
        expect(result).to be_a(Pubid::Export::FlavorResult)
      end

      it "has identifier types" do
        expect(result.identifier_types.size).to be > 0
      end
    end

    context "ITU flavor" do
      let(:exporter) { described_class.new(:itu) }
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
