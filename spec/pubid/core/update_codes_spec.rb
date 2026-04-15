# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Core::UpdateCodes do
  describe ".apply" do
    describe "exact match" do
      it "rewrites ISO/TR 17716.2 to ISO/TR 17716" do
        expect(described_class.apply("ISO/TR 17716.2",
                                     :iso)).to eq("ISO/TR 17716")
      end

      it "rewrites ISO/TR 17716.2(E) to ISO/TR 17716(E)" do
        expect(described_class.apply("ISO/TR 17716.2(E)",
                                     :iso)).to eq("ISO/TR 17716(E)")
      end

      it "rewrites IECEE TRF case-correction entry" do
        expect(described_class.apply("IECEE TRF cispr 15N:2022", :iec))
          .to eq("IECEE TRF CISPR 15N:2022")
      end

      it "passes through unknown identifiers unchanged" do
        expect(described_class.apply("ISO/TR 17716",
                                     :iso)).to eq("ISO/TR 17716")
      end
    end

    describe "regex match" do
      it "rewrites NBS CIRC sup via regex" do
        expect(described_class.apply("NBS CIRC sup",
                                     :nist)).to eq("NBS CIRC 24e7sup")
      end

      it "does not match partial NBS CIRC supply" do
        expect(described_class.apply("NBS CIRC supply list",
                                     :nist)).to eq("NBS CIRC supply list")
      end
    end

    describe "whitespace normalization" do
      it "strips leading/trailing whitespace before matching" do
        expect(described_class.apply("  ISO/TR 17716.2  ",
                                     :iso)).to eq("ISO/TR 17716")
      end
    end

    describe "flavor isolation" do
      it "ISO entries do not affect IEC" do
        expect(described_class.apply("ISO/TR 17716.2",
                                     :iec)).to eq("ISO/TR 17716.2")
      end

      it "IEC entries do not affect ISO" do
        expect(described_class.apply("IECEE TRF cispr 15N:2022", :iso))
          .to eq("IECEE TRF cispr 15N:2022")
      end
    end

    describe "V1-compatible behavior" do
      it "rewrites ISO/R 657/IV to ISO/R 657-4:1969" do
        expect(described_class.apply("ISO/R 657/IV",
                                     :iso)).to eq("ISO/R 657-4:1969")
      end
    end

    describe "memoization" do
      it "returns the same object for repeated flavor lookups" do
        first = described_class.for_flavor(:iso)
        second = described_class.for_flavor(:iso)
        expect(first).to equal(second)
      end
    end

    describe "frozen maps" do
      it "returns a frozen map" do
        expect(described_class.for_flavor(:iso)).to be_frozen
      end
    end
  end
end
