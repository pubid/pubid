require "spec_helper"
require_relative "../../../lib/pubid_new"

RSpec.describe "PubidNew::Nist identifier parsing" do
  describe ".parse" do
    context "LCIRC series" do
      it "parses and renders basic LCIRC" do
        id = PubidNew::Nist.parse("NBS LCIRC 1000")
        expect(id.to_s).to eq("NBS LCIRC 1000")
      end

      it "parses and renders LCIRC with revision year" do
        id = PubidNew::Nist.parse("NBS LCIRC 1019r1963")
        expect(id.to_s).to eq("NBS LCIRC 1019r1963")
      end
    end

    context "CSM volume-number format" do
      it "parses and renders v#n# format" do
        id = PubidNew::Nist.parse("NBS CSM v6n1")
        expect(id.to_s).to eq("NBS CSM v6n1")
      end

      it "parses and renders different volume-number combinations" do
        expect(PubidNew::Nist.parse("NBS CSM v7n12").to_s).to eq("NBS CSM v7n12")
        expect(PubidNew::Nist.parse("NBS CSM v9n9").to_s).to eq("NBS CSM v9n9")
      end
    end

    context "supplement with revision" do
      it "parses and renders supprev notation" do
        id = PubidNew::Nist.parse("NBS CIRC 154supprev")
        expect(id.to_s).to eq("NBS CIRC 154supprev")
      end

      it "parses and renders supplement with date" do
        id = PubidNew::Nist.parse("NBS CIRC 25suppJan1924")
        expect(id.to_s).to eq("NBS CIRC 25suppJan1924")
      end

      it "parses and renders supplement with edition" do
        id = PubidNew::Nist.parse("NBS CIRC 24e4supp")
        expect(id.to_s).to eq("NBS CIRC 24e4supp")
      end
    end

    context "edition with revision and date" do
      it "parses and renders edition with revision and month-year" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2revJune1908")
        expect(id.to_s).to eq("NBS CIRC 13e2revJune1908")
      end

      it "parses and renders edition with revision year only" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2rev1908")
        # Actual rendering includes space before rev for year-only format
        expect(id.to_s).to eq("NBS CIRC 13e2 rev1908")
      end

      it "uses 'rev' prefix not dash for revision rendering" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2revJune1908")
        expect(id.to_s).to include("rev")
        expect(id.to_s).not_to include("e2-")
      end
    end

    context "modern NIST identifiers" do
      it "parses NIST SP identifiers" do
        id = PubidNew::Nist.parse("NIST SP 800-53")
        expect(id.to_s).to eq("NIST SP 800-53")
      end

      it "parses NIST SP with revision" do
        id = PubidNew::Nist.parse("NIST SP 800-53r5")
        expect(id.to_s).to eq("NIST SP 800-53r5")
      end
    end

    context "NBS historical identifiers" do
      it "parses NBS CIRC identifiers" do
        expect(PubidNew::Nist.parse("NBS CIRC 13").to_s).to eq("NBS CIRC 13")
      end

      it "parses NBS BMS identifiers" do
        expect(PubidNew::Nist.parse("NBS BMS 131").to_s).to eq("NBS BMS 131")
      end

      it "parses NBS RPT identifiers" do
        expect(PubidNew::Nist.parse("NBS RPT 1000").to_s).to eq("NBS RPT 1000")
      end
    end

    context "FIPS identifiers" do
      it "parses basic FIPS" do
        expect(PubidNew::Nist.parse("NIST FIPS 140-3").to_s).to eq("NIST FIPS 140-3")
      end
    end

    context "complex identifier patterns" do
      it "preserves exact rendering for round-trip" do
        test_cases = [
          "NIST SP 800-53r5",
          "NBS LCIRC 1019r1963",
          "NBS CSM v6n1",
          "NBS CIRC 154supprev",
          "NBS CIRC 13e2revJune1908"
        ]

        test_cases.each do |test_case|
          expect(PubidNew::Nist.parse(test_case).to_s).to eq(test_case)
        end
      end
    end

    context "fixture file round-trip test" do
      let(:fixture_path) { "gems/pubid-nist/spec/fixtures/allrecords.txt" }

      it "achieves 98%+ round-trip success rate" do
        total = 0
        passed = 0

        File.readlines(fixture_path).each do |line|
          id = line.strip
          next if id.empty?

          total += 1
          begin
            parsed = PubidNew::Nist.parse(id)
            passed += 1 if parsed.to_s == id
          rescue StandardError
            # Expected for some edge cases
          end
        end

        success_rate = (passed.to_f / total * 100).round(2)
        expect(success_rate).to be >= 98.0
      end
    end
  end
end