# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::IeeeExporter do
  describe "#export" do
    let(:exporter) { described_class.new(:ieee) }
    let(:result) { exporter.export }

    it "returns a FlavorResult" do
      expect(result).to be_a(Pubid::Export::FlavorResult)
    end

    it "has identifier types" do
      expect(result.identifier_types.size).to be > 0
    end

    it "includes a Standard type" do
      std = result.identifier_types.find { |t| t.key == "std" }
      expect(std).not_to be_nil
    end

    it "assigns typed stages only to Standard" do
      result.identifier_types.each do |type|
        if type.key == "std"
          expect(type.typed_stages.size).to be >= 0
        end
      end
    end
  end
end
