require "spec_helper"

RSpec.describe PubidNew::Plateau do
  describe ".parse" do
    context "PLATEAU Handbook identifiers" do
      it "parses PLATEAU Handbook #00 第1.0版" do
        result = described_class.parse("PLATEAU Handbook #00 第1.0版")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::Handbook)
        expect(result.number).to eq(0)
        expect(result.edition).to eq("1.0")
        expect(result.to_s).to eq("PLATEAU Handbook #00 第1.0版")
      end

      it "parses PLATEAU Handbook #03-1 第1.0版 with annex" do
        result = described_class.parse("PLATEAU Handbook #03-1 第1.0版")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::Handbook)
        expect(result.number).to eq(3)
        expect(result.annex).to eq(1)
        expect(result.edition).to eq("1.0")
        expect(result.to_s).to eq("PLATEAU Handbook #03-1 第1.0版")
      end
    end

    context "PLATEAU Technical Report identifiers" do
      it "parses PLATEAU Technical Report #01" do
        result = described_class.parse("PLATEAU Technical Report #01")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::TechnicalReport)
        expect(result.number).to eq(1)
        expect(result.to_s).to eq("PLATEAU Technical Report #01")
      end

      it "parses PLATEAU Technical Report #46-1 with annex" do
        result = described_class.parse("PLATEAU Technical Report #46-1")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::TechnicalReport)
        expect(result.number).to eq(46)
        expect(result.annex).to eq(1)
        expect(result.to_s).to eq("PLATEAU Technical Report #46-1")
      end
    end

    context "PLATEAU Annex identifiers" do
      it "parses PLATEAU Handbook #00 第1.0版 Annex A" do
        result = described_class.parse("PLATEAU Handbook #00 第1.0版 Annex A")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::Annex)
        expect(result.letter).to eq("A")
        expect(result.base_identifier).to be_a(PubidNew::Plateau::Identifiers::Handbook)
        expect(result.base_identifier.number).to eq(0)
        expect(result.base_identifier.edition).to eq("1.0")
        expect(result.to_s).to eq("PLATEAU Handbook #00 第1.0版 Annex A")
      end

      it "parses PLATEAU Technical Report #01 Annex B" do
        result = described_class.parse("PLATEAU Technical Report #01 Annex B")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::Annex)
        expect(result.letter).to eq("B")
        expect(result.base_identifier).to be_a(PubidNew::Plateau::Identifiers::TechnicalReport)
        expect(result.base_identifier.number).to eq(1)
        expect(result.to_s).to eq("PLATEAU Technical Report #01 Annex B")
      end

      it "parses PLATEAU Handbook #03-1 第2.0版 Annex C" do
        result = described_class.parse("PLATEAU Handbook #03-1 第2.0版 Annex C")

        expect(result).to be_a(PubidNew::Plateau::Identifiers::Annex)
        expect(result.letter).to eq("C")
        expect(result.base_identifier.number).to eq(3)
        expect(result.base_identifier.annex).to eq(1)
        expect(result.base_identifier.edition).to eq("2.0")
        expect(result.to_s).to eq("PLATEAU Handbook #03-1 第2.0版 Annex C")
      end
    end

    context "round-trip fidelity" do
      [
        "PLATEAU Handbook #00 第1.0版",
        "PLATEAU Handbook #03-1 第1.0版",
        "PLATEAU Technical Report #01",
        "PLATEAU Technical Report #46-1",
        "PLATEAU Handbook #00 第1.0版 Annex A",
        "PLATEAU Technical Report #01 Annex B",
        "PLATEAU Handbook #03-1 第2.0版 Annex C"
      ].each do |identifier|
        it "round-trips #{identifier}" do
          result = described_class.parse(identifier)
          expect(result.to_s).to eq(identifier)
        end
      end
    end
  end
end