require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Ieee::Identifiers::Base do
  describe ".parse" do
    context "basic IEEE identifiers" do
      it "parses IEEE Std identifiers" do
        id = PubidNew::Ieee.parse("IEEE Std 623-1976")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::Base)
        expect(id.to_s).to eq("IEEE Std 623-1976")
      end

      it "parses IEEE Std with letter prefix codes" do
        id = PubidNew::Ieee.parse("IEEE Std C37.111-2013")
        expect(id.to_s).to eq("IEEE Std C37.111-2013")
      end

      it "parses IEEE P (project) identifiers" do
        id = PubidNew::Ieee.parse("IEEE P11073-10404-10419")
        expect(id.to_s).to eq("IEEE P11073-10404-10419")
      end

      it "parses AIEE identifiers" do
        id = PubidNew::Ieee.parse("AIEE No 14-1925")
        expect(id.to_s).to eq("AIEE No 14-1925")
      end
    end

    context "IEC identifiers" do
      it "parses basic IEC identifiers" do
        id = PubidNew::Ieee.parse("IEC 61523-4")
        expect(id.to_s).to eq("IEC 61523-4")
      end

      it "parses IEC with edition format" do
        id = PubidNew::Ieee.parse("IEC 61671-2 Edition 1.0 2016-04")
        expect(id.to_s).to eq("IEC 61671-2 Edition 1.0 2016-04")
      end
    end

    context "parenthetical content" do
      it "preserves multi-part adoptions with commas" do
        id = PubidNew::Ieee.parse("IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)")
        expect(id.to_s).to eq("IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)")
      end

      it "preserves descriptive parenthetical notes" do
        id = PubidNew::Ieee.parse("AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::Base)
        expect(id.to_s).to eq("AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)")
      end
    end

    context "round-trip parsing" do
      it "preserves exact rendering" do
        test_cases = [
          "IEEE Std 623-1976",
          "IEEE Std C37.111-2013",
          "IEEE P11073-10404-10419",
          "IEC 61523-4",
          "AIEE No 14-1925",
          "IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)",
          "AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)"
        ]

        test_cases.each do |test_case|
          expect(PubidNew::Ieee.parse(test_case).to_s).to eq(test_case)
        end
      end
    end
  end
end