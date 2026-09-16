# frozen_string_literal: true

require "spec_helper"

# The corpus of the relaton GB flavor: specs, fixtures and VCR cassettes.
GB_REFERENCES = [
  "GB/T 1.1",
  "GB/T 1.1-2000",
  "GB/T 1.1-2009",
  "GB/T 1.1-2020",
  "GB/T 20223-2006",
  "GB/T 20223-2014",
  "GB/T 5606.1-2004",
  "GB/T 5606.1-1996",
  "JB/T 13368-2018",
  "T/GZAEPI 001-2018",
  "GB/T 5606 (all parts)",
  "GBn 123-1990",
].freeze

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

    context "confidential national series (GBn)" do
      subject(:parsed) { described_class.parse("GBn 123-1990") }

      it "captures publisher code as GBn" do
        expect(parsed.publisher_code).to eq("GBn")
      end

      it "has no mandate" do
        expect(parsed.mandate).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("GBn 123-1990")
      end

      it "round-trips the recommended form" do
        expect(described_class.parse("GBn/T 123-1990").to_s)
          .to eq("GBn/T 123-1990")
      end

      it "routes through Pubid.parse" do
        expect(Pubid.parse("GBn 123-1990")).to be_a(described_class)
      end
    end

    it "raises on malformed input" do
      expect { described_class.parse("GB") }
        .to raise_error(Parslet::ParseFailed)
    end
  end

  describe "#to_hash" do
    subject(:hash) { described_class.parse("GB/T 20223-2006").to_hash }

    it "serializes the year as a flat scalar" do
      expect(hash["year"]).to eq("2006")
    end

    it "carries no nested date component" do
      expect(hash).not_to have_key("date")
    end
  end

  describe "serialization round trip" do
    GB_REFERENCES.each do |reference|
      context reference do
        subject(:identifier) { described_class.parse(reference) }

        it "renders the input" do
          expect(identifier.to_s).to eq(reference)
        end

        it "is equal after from_hash" do
          expect(described_class.from_hash(identifier.to_hash))
            .to eq(identifier)
        end

        it "renders the input after from_hash" do
          expect(described_class.from_hash(identifier.to_hash).to_s)
            .to eq(reference)
        end

        it "resolves through Pubid.from_hash" do
          expect(Pubid.from_hash(identifier.to_hash)).to eq(identifier)
        end
      end
    end
  end

  describe "the em-dash year separator" do
    # Chinese typography prints an em dash. Pubid normalizes it to an ASCII
    # hyphen, so both spellings name the same document.
    it "renders an ASCII hyphen" do
      expect(described_class.parse("T/ZS 0467—2023").to_s)
        .to eq("T/ZS 0467-2023")
    end

    it "gives equal identifiers for both spellings" do
      expect(described_class.parse("T/GZAEPI 001—2018"))
        .to eq(described_class.parse("T/GZAEPI 001-2018"))
    end
  end
end
