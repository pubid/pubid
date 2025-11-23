require "spec_helper"

RSpec.describe PubidNew::Ieee::Parser do
  describe "parsing through module interface" do
    context "basic IEEE identifiers" do
      it "parses IEEE Std identifiers" do
        expect { PubidNew::Ieee.parse("IEEE Std 623-1976") }.not_to raise_error
        expect { PubidNew::Ieee.parse("IEEE Std C37.111-2013") }.not_to raise_error
      end

      it "parses IEEE P (project) identifiers" do
        expect { PubidNew::Ieee.parse("IEEE P11073-10404-10419") }.not_to raise_error
      end

      it "parses AIEE identifiers" do
        expect { PubidNew::Ieee.parse("AIEE No 14-1925") }.not_to raise_error
      end
    end

    context "IEC identifiers" do
      it "parses basic IEC identifiers" do
        expect { PubidNew::Ieee.parse("IEC 61523-4") }.not_to raise_error
        expect { PubidNew::Ieee.parse("IEC 61671-2") }.not_to raise_error
      end

      it "parses IEC with edition format" do
        expect { PubidNew::Ieee.parse("IEC 61671-2 Edition 1.0 2016-04") }.not_to raise_error
      end
    end

    context "parenthetical content" do
      it "parses single adoption in parentheses" do
        expect { PubidNew::Ieee.parse("AIEE No 14-1925 (AESC C22-1925)") }.not_to raise_error
      end

      it "parses multi-part adoptions with commas" do
        expect { PubidNew::Ieee.parse("IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)") }.not_to raise_error
      end

      it "parses descriptive parenthetical notes" do
        expect { PubidNew::Ieee.parse("AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)") }.not_to raise_error
      end
    end

    context "IEC edition with year-month and IEEE adoption" do
      it "parses complex IEC/IEEE copublished format" do
        expect { PubidNew::Ieee.parse("IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)") }.not_to raise_error
      end

      it "parses IEEE with IEC edition in parentheses" do
        expect { PubidNew::Ieee.parse("IEEE Std C37.111-2013 (IEC 60255-24 Edition 2.0 2013-04)") }.not_to raise_error
      end
    end

    context "code separator patterns" do
      it "parses codes with letter prefixes using dots" do
        expect { PubidNew::Ieee.parse("IEEE Std C37.111-2013") }.not_to raise_error
      end

      it "parses P-prefix codes using dashes" do
        expect { PubidNew::Ieee.parse("IEEE P11073-10404-10419") }.not_to raise_error
      end

      it "parses traditional IEEE codes with dots" do
        expect { PubidNew::Ieee.parse("IEEE Std 802.11-2016") }.not_to raise_error
      end
    end
  end
end