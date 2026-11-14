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

    # Regression guard for #720: extract_attributes called lutaml's
    # nonexistent `model_attributes`, so the attributes column was always
    # empty for every flavor.
    context "attributes column (#720)" do
      let(:exporter) { described_class.new(:iso) }

      it "is non-empty" do
        expect(exporter.export.attributes).not_to be_empty
      end

      it "names the flavor's declared attributes" do
        expect(exporter.export.attributes).to include("number", "publisher")
      end

      it "matches the lead identifier class's declared lutaml attributes" do
        klass = Pubid::Iso.identifier_types.first
        expected = klass.attributes.keys.map(&:to_s)
        expect(exporter.export.attributes).to eq(expected)
      end
    end
  end

  describe "#export over every registered flavor (#720)" do
    it "exports a non-empty attributes column for every flavor" do
      Pubid::Export::Exporter::FLAVORS.each do |flavor|
        result = described_class.new(flavor).export
        expect(result).not_to be_nil, "no export for #{flavor}"
        expect(result.attributes).not_to be_empty,
                                         "empty attributes column for #{flavor}"
      end
    end
  end
end
