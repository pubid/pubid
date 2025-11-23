require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Nist::Identifiers::CommercialStandardsMonthly do
  describe ".parse" do
    context "CSM v#n# format" do
      it "parses basic v#n# format" do
        id = PubidNew::Nist.parse("NBS CSM v6n1")
        expect(id).to be_a(PubidNew::Nist::Identifiers::CommercialStandardsMonthly)
        expect(id.to_s).to eq("NBS CSM v6n1")
      end

      it "parses different volume-number combinations" do
        expect(PubidNew::Nist.parse("NBS CSM v7n12").to_s).to eq("NBS CSM v7n12")
        expect(PubidNew::Nist.parse("NBS CSM v9n9").to_s).to eq("NBS CSM v9n9")
        expect(PubidNew::Nist.parse("NBS CSM v1n1").to_s).to eq("NBS CSM v1n1")
      end

      it "handles double-digit volumes and numbers" do
        expect(PubidNew::Nist.parse("NBS CSM v10n10").to_s).to eq("NBS CSM v10n10")
      end
    end

    context "round-trip parsing" do
      it "preserves exact rendering" do
        test_cases = [
          "NBS CSM v6n1",
          "NBS CSM v7n12",
          "NBS CSM v9n9"
        ]

        test_cases.each do |test_case|
          expect(PubidNew::Nist.parse(test_case).to_s).to eq(test_case)
        end
      end
    end

    context "class attributes" do
      let(:id) { PubidNew::Nist.parse("NBS CSM v6n1") }

      it "has correct publisher" do
        expect(id.publisher).to eq("NBS")
      end

      it "has correct series" do
        expect(id.series).to eq("CSM")
      end
    end
  end
end