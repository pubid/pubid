# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ecma::Identifier do
  describe ".parse" do
    context "with a plain standard" do
      let(:parsed) { described_class.parse("ECMA-411") }

      it "parses as a Standard" do
        expect(parsed).to be_a(Pubid::Ecma::Identifiers::Standard)
      end

      it "parses the number" do
        expect(parsed.number).to eq("411")
      end

      it "has no part" do
        expect(parsed.part).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ECMA-411")
      end

      it "renders without publisher" do
        expect(parsed.to_s(with_publisher: false)).to eq("-411")
      end
    end

    context "with a standard split into parts" do
      let(:parsed) { described_class.parse("ECMA-418-1") }

      it "parses as a Standard" do
        expect(parsed).to be_a(Pubid::Ecma::Identifiers::Standard)
      end

      it "parses the number and part" do
        expect(parsed.number).to eq("418")
        expect(parsed.part).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ECMA-418-1")
      end

      it "renders without publisher" do
        expect(parsed.to_s(with_publisher: false)).to eq("-418-1")
      end
    end

    context "with a technical report" do
      let(:parsed) { described_class.parse("ECMA TR/101") }

      it "parses as a TechnicalReport" do
        expect(parsed).to be_a(Pubid::Ecma::Identifiers::TechnicalReport)
      end

      it "parses the number" do
        expect(parsed.number).to eq("101")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ECMA TR/101")
      end

      it "renders without publisher" do
        expect(parsed.to_s(with_publisher: false)).to eq("TR/101")
      end
    end

    context "with a memento" do
      let(:parsed) { described_class.parse("ECMA MEM/1970") }

      it "parses as a Memento" do
        expect(parsed).to be_a(Pubid::Ecma::Identifiers::Memento)
      end

      it "parses the number" do
        expect(parsed.number).to eq("1970")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ECMA MEM/1970")
      end

      it "renders without publisher" do
        expect(parsed.to_s(with_publisher: false)).to eq("MEM/1970")
      end
    end

    context "with an over-long input" do
      it "raises ArgumentError before parsing" do
        expect { described_class.parse("ECMA-#{'1' * 1001}") }
          .to raise_error(ArgumentError, /maximum length/)
      end
    end

    context "with an unparseable string" do
      it "raises" do
        expect { described_class.parse("NOT-ECMA") }
          .to raise_error(RuntimeError, /Failed to parse/)
      end
    end
  end

  describe "Pubid::Ecma.parse" do
    it "delegates to Identifier.parse" do
      expect(Pubid::Ecma.parse("ECMA-13")).to be_a(Pubid::Ecma::Identifiers::Standard)
    end
  end
end
