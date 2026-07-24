# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Gb::Identifier do
  describe ".parse" do
    context "national recommended standard" do
      subject(:parsed) { described_class.parse("GB/T 20223-2006") }

      it "captures publisher code" do
        expect(parsed.publisher_code).to eq("GB")
      end

      it "captures mandate as T" do
        expect(parsed.mandate).to eq("T")
      end

      it "captures number" do
        expect(parsed.number).to eq("20223")
      end

      it "captures year" do
        expect(parsed.year).to eq("2006")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("GB/T 20223-2006")
      end
    end

    context "national mandatory standard" do
      subject(:parsed) { described_class.parse("GB 1234-2010") }

      it "has no mandate" do
        expect(parsed.mandate).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("GB 1234-2010")
      end
    end

    context "national guideline (Z suffix)" do
      it "captures Z mandate" do
        expect(described_class.parse("GB/Z 123-2008").mandate).to eq("Z")
      end
    end

    context "with part" do
      subject(:parsed) { described_class.parse("GB/T 5606.1-2004") }

      it "captures part" do
        expect(parsed.part).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("GB/T 5606.1-2004")
      end
    end

    context "all parts form" do
      it "round-trips the all-parts flag" do
        parsed = described_class.parse("GB/T 5606 (all parts)")
        expect(parsed.all_parts).to be(true)
        expect(parsed.to_s).to eq("GB/T 5606 (all parts)")
      end
    end

    context "industry standard" do
      it "round-trips" do
        expect(described_class.parse("JB/T 13368-2018").to_s)
          .to eq("JB/T 13368-2018")
      end
    end

    context "social-group standard (T/{ORG})" do
      subject(:parsed) { described_class.parse("T/GZAEPI 001—2018") }

      it "captures publisher code as T/GZAEPI" do
        expect(parsed.publisher_code).to eq("T/GZAEPI")
      end

      it "captures year even with em-dash separator" do
        expect(parsed.year).to eq("2018")
      end

      it "round-trips (em-dash normalized to ASCII dash)" do
        expect(parsed.to_s).to eq("T/GZAEPI 001-2018")
      end
    end

    it "raises on malformed input" do
      expect { described_class.parse("GB") }.to raise_error(/Failed to parse/)
    end
  end
end
