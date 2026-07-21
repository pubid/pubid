require "spec_helper"

RSpec.describe Pubid::Ccsds do
  describe "SingleIdentifier superclass resolution" do
    # Regression: Pubid::Ccsds::Identifier is a module (with self.parse),
    # so an unqualified `class SingleIdentifier < Identifier` resolves to
    # the local module and raises TypeError. The superclass must be
    # qualified as ::Pubid::Identifier.
    it "inherits directly from ::Pubid::Identifier" do
      expect(Pubid::Ccsds::SingleIdentifier.superclass)
        .to eq(::Pubid::Identifier)
    end

    it "does not raise on first load" do
      expect { Pubid::Ccsds::SingleIdentifier }.not_to raise_error
    end
  end

  describe ".parse" do
    context "basic CCSDS identifiers" do
      it "parses CCSDS 120.0-G-4" do
        result = described_class.parse("CCSDS 120.0-G-4")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.number).to eq("120")
        expect(result.part).to eq("0")
        expect(result.type).to eq("G")
        expect(result.edition).to eq("4")

        expect(result.to_s).to eq("CCSDS 120.0-G-4")
      end

      it "parses CCSDS A20.1-Y-1 with series prefix" do
        result = described_class.parse("CCSDS A20.1-Y-1")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.number).to eq("A20")
        expect(result.part).to eq("1")
        expect(result.type).to eq("Y")
        expect(result.edition).to eq("1")

        expect(result.to_s).to eq("CCSDS A20.1-Y-1")
      end

      it "parses CCSDS 100.0-G-1-S with retired suffix" do
        result = described_class.parse("CCSDS 100.0-G-1-S")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.number).to eq("100")
        expect(result.part).to eq("0")
        expect(result.type).to eq("G")
        expect(result.edition).to eq("1")
        expect(result.suffix).to eq("S")

        expect(result.to_s).to eq("CCSDS 100.0-G-1-S")
      end

      it "parses CCSDS 401.0-B-S" do
        result = described_class.parse("CCSDS 401.0-B-S")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.number).to eq("401")
        expect(result.part).to eq("0")
        expect(result.type).to eq("B")
        expect(result.edition).to be_nil
        expect(result.suffix).to eq("S")

        expect(result.to_s).to eq("CCSDS 401.0-B-S")
      end

      it "parses CCSDS A01.2-Y-4.1-S with decimal edition" do
        result = described_class.parse("CCSDS A01.2-Y-4.1-S")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.number).to eq("A01")
        expect(result.part).to eq("2")
        expect(result.type).to eq("Y")
        expect(result.edition).to eq("4.1")
        expect(result.suffix).to eq("S")

        expect(result.to_s).to eq("CCSDS A01.2-Y-4.1-S")
      end
    end

    context "CCSDS identifiers with corrigenda" do
      it "parses CCSDS 131.2-O-1-S Cor. 1" do
        result = described_class.parse("CCSDS 131.2-O-1-S Cor. 1")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Corrigendum)
        expect(result.number).to eq("1")

        expect(result.base).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.base.number).to eq("131")
        expect(result.base.part).to eq("2")
        expect(result.base.type).to eq("O")
        expect(result.base.edition).to eq("1")
        expect(result.base.suffix).to eq("S")

        expect(result.to_s).to eq("CCSDS 131.2-O-1-S Cor. 1")
      end

      it "parses CCSDS 912.1-B-2-S Cor. 1" do
        result = described_class.parse("CCSDS 912.1-B-2-S Cor. 1")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Corrigendum)
        expect(result.number).to eq("1")

        expect(result.base).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.base.number).to eq("912")
        expect(result.base.part).to eq("1")
        expect(result.base.type).to eq("B")
        expect(result.base.edition).to eq("2")
        expect(result.base.suffix).to eq("S")

        expect(result.to_s).to eq("CCSDS 912.1-B-2-S Cor. 1")
      end
    end

    context "CCSDS identifiers with language translation" do
      it "parses CCSDS 551.1-O-2 - Russian Translated" do
        result = described_class.parse("CCSDS 551.1-O-2 - Russian Translated")

        expect(result).to be_a(Pubid::Ccsds::Identifiers::Base)
        expect(result.number).to eq("551")
        expect(result.part).to eq("1")
        expect(result.type).to eq("O")
        expect(result.edition).to eq("2")
        expect(result.language).to eq("Russian")

        expect(result.to_s).to eq("CCSDS 551.1-O-2 - Russian Translated")
      end
    end

    context "round-trip fidelity" do
      [
        "CCSDS 120.0-G-4",
        "CCSDS A20.1-Y-1",
        "CCSDS 100.0-G-1-S",
        "CCSDS 131.2-O-1-S Cor. 1",
        "CCSDS 551.1-O-2 - Russian Translated",
        "CCSDS 401.0-B-S",
        "CCSDS 912.1-B-2-S Cor. 1",
        "CCSDS A01.2-Y-4.1-S",
      ].each do |identifier|
        it "round-trips #{identifier}" do
          result = described_class.parse(identifier)
          expect(result.to_s).to eq(identifier)
        end
      end
    end
  end
end
