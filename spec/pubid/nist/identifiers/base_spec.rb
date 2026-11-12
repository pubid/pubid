require "spec_helper"
require_relative "../../../../lib/pubid"

RSpec.describe Pubid::Nist::Identifier do
  describe ".parse" do
    context "basic NIST identifiers" do
      it "parses NIST SP identifiers" do
        id = Pubid::Nist.parse("NIST SP 800-53")
        expect(id).to be_a(described_class)
        expect(id.to_s).to eq("NIST SP 800-53")
      end

      it "parses NIST SP with revision" do
        id = Pubid::Nist.parse("NIST SP 800-53r5")
        expect(id.to_s).to eq("NIST SP 800-53r5")
      end

      it "parses NIST FIPS identifiers" do
        id = Pubid::Nist.parse("NIST FIPS 140-3")
        expect(id.to_s).to eq("FIPS PUB 140-3")
      end

      it "parses NBS historical identifiers" do
        id = Pubid::Nist.parse("NBS BMS 131")
        expect(id.to_s).to eq("NBS BMS 131")
      end
    end

    context "round-trip parsing" do
      it "preserves exact rendering" do
        # "NIST FIPS 140-3" is a parse spelling; the official printed face
        # ("FIPS PUB <number>", owner ruling 2026-11-12) is what renders.
        test_cases = {
          "NIST SP 800-53" => "NIST SP 800-53",
          "NIST SP 800-53r5" => "NIST SP 800-53r5",
          "NIST FIPS 140-3" => "FIPS PUB 140-3",
          "NBS BMS 131" => "NBS BMS 131",
          "NBS RPT 1000" => "NBS RPT 1000",
        }

        test_cases.each do |test_case, rendered|
          expect(Pubid::Nist.parse(test_case).to_s).to eq(rendered)
          expect(Pubid::Nist.parse(rendered).to_s).to eq(rendered)
        end
      end
    end
  end
end
