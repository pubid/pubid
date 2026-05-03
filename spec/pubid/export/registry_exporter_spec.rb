# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::RegistryExporter do
  describe "#export" do
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
  end
end
