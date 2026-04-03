# frozen_string_literal: true

require "rspec"
require_relative "../../lib/pubid/iso"

RSpec.describe Pubid::Identifier do
  describe "#root" do
    context "with supplement identifier" do
      it "returns base for amendment" do
        id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
        expect(id.root.to_s).to eq("ISO 9001:2015")
      end

      it "returns base for corrigendum" do
        id = Pubid::Iso.parse("ISO 9001:2015/Cor 1:2020")
        expect(id.root.to_s).to eq("ISO 9001:2015")
      end

      it "returns base for nested supplements" do
        id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020/Cor 1:2021")
        expect(id.root.to_s).to eq("ISO 9001:2015")
      end
    end

    context "with base identifier" do
      it "returns self for standard" do
        id = Pubid::Iso.parse("ISO 9001:2015")
        expect(id.root).to eq(id)
      end

      it "returns self for undated standard" do
        id = Pubid::Iso.parse("ISO 9001")
        expect(id.root).to eq(id)
      end
    end
  end
end
