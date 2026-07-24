# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Un::Identifier do
  describe ".parse" do
    context "TRADE/CEFACT/2004/32" do
      subject(:parsed) { described_class.parse("TRADE/CEFACT/2004/32") }

      it "captures path" do
        expect(parsed.path).to eq(%w[TRADE CEFACT 2004])
      end

      it "captures number" do
        expect(parsed.number).to eq("32")
      end

      it "captures year" do
        expect(parsed.year).to eq("2004")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("TRADE/CEFACT/2004/32")
      end
    end

    context "TRADE/WP.4/R.1068 (revision marker)" do
      it "treats R.1068 as the number" do
        parsed = described_class.parse("TRADE/WP.4/R.1068")
        expect(parsed.number).to eq("R.1068")
      end

      it "round-trips" do
        expect(described_class.parse("TRADE/WP.4/R.1068").to_s)
          .to eq("TRADE/WP.4/R.1068")
      end
    end

    context "A/RES/78/1 (General Assembly resolution)" do
      it "round-trips without raising" do
        expect(described_class.parse("A/RES/78/1").to_s).to eq("A/RES/78/1")
      end

      it "does not treat 78 as year (session number, not year)" do
        expect(described_class.parse("A/RES/78/1").year).to be_nil
      end
    end

    context "optional UN prefix" do
      it "strips the UN prefix" do
        parsed = described_class.parse("UN A/RES/78/1")
        expect(parsed.to_s).to eq("A/RES/78/1")
      end
    end

    it "raises on malformed input" do
      expect { described_class.parse("TRADE") }.to raise_error(/Failed to parse/)
    end
  end
end
