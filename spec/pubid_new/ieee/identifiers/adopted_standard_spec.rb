require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Ieee::Identifiers::AdoptedStandard do
  describe ".parse" do
    context "single adoption in parentheses" do
      it "parses AIEE with AESC adoption" do
        id = PubidNew::Ieee.parse("AIEE No 14-1925 (AESC C22-1925)")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::AdoptedStandard)
        # Dash separator is now correctly preserved
        expect(id.to_s).to eq("AIEE No 14-1925 (AESC C22-1925)")
      end
    end

    context "IEC edition with IEEE adoption" do
      it "parses IEC with edition and IEEE Std in parentheses" do
        id = PubidNew::Ieee.parse("IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::AdoptedStandard)
        expect(id.to_s).to eq("IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)")
      end

      it "parses IEEE with IEC edition in parentheses" do
        id = PubidNew::Ieee.parse("IEEE Std C37.111-2013 (IEC 60255-24 Edition 2.0 2013-04)")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::AdoptedStandard)
        # IEC code preserves dash separator
        expect(id.to_s).to eq("IEEE Std C37.111-2013 (IEC 60255-24 Edition 2.0 2013-04)")
      end
    end

    context "round-trip parsing" do
      it "preserves rendering (with known limitations)" do
        test_cases = {
          "IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)" =>
            "IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)",
          "IEEE Std C37.111-2013 (IEC 60255-24 Edition 2.0 2013-04)" =>
            "IEEE Std C37.111-2013 (IEC 60255-24 Edition 2.0 2013-04)"
        }

        test_cases.each do |input, expected|
          expect(PubidNew::Ieee.parse(input).to_s).to eq(expected)
        end
      end
    end
  end
end