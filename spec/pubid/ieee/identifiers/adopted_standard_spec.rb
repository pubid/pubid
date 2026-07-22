require "spec_helper"
require_relative "../../../../lib/pubid"

RSpec.describe Pubid::Ieee::Identifiers::AdoptedStandard do
  describe ".parse" do
    context "single adoption in parentheses" do
      it "parses AIEE with AESC adoption" do
        id = Pubid::Ieee.parse("AIEE No 14-1925 (AESC C22-1925)")
        expect(id).to be_a(described_class)

        expect(id.ieee_identifier).to be_a(Pubid::Ieee::Aiee::Identifier)
        expect(id.ieee_identifier.to_s).to eq("AIEE No 14-1925")

        expect(id.adopted_identifiers.first).to be_a(Pubid::Ieee::Identifier)
        expect(id.adopted_identifiers.first.publisher).to eq("AESC")
        expect(id.adopted_identifiers.first.to_s).to eq("AESC C22-1925")

        # Dash separator is now correctly preserved
        expect(id.to_s).to eq("AIEE No 14-1925 (AESC C22-1925)")
      end
    end

    context "IEC edition with IEEE adoption" do
      # TODO: This is very weird but preserving behavior for now:
      # "Published in alignment with IEEE Std 1801™-2013" is not "Adopted" but
      # is "IEEE adopted by IEC"...
      it "parses IEC with edition and IEEE Std in parentheses" do
        id = Pubid::Ieee.parse("IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)")
        expect(id).to be_a(described_class)
        expect(id.ieee_identifier.to_s).to eq("IEC 61523-4 Edition 1.0 2015-03")
        expect(id.adopted_identifiers.first.to_s).to eq("IEEE Std 1801-2013")
        # Dash separator is now correctly preserved
        expect(id.to_s).to eq("IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)")
      end

      it "parses IEEE with IEC edition in parentheses" do
        id = Pubid::Ieee.parse("IEEE Std C37.111-2013 (IEC 60255-24 Edition 2.0 2013-04)")
        expect(id).to be_a(described_class)

        expect(id.ieee_identifier).to be_a(Pubid::Ieee::Identifier)
        expect(id.ieee_identifier.to_s).to eq("IEEE Std C37.111-2013")

        expect(id.adopted_identifiers.first).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
        expect(id.adopted_identifiers.first.to_s).to eq("IEC 60255-24:2013-04 ED2.0")

        expect(id.to_s).to eq("IEEE Std C37.111-2013 (IEC 60255-24:2013-04 ED2.0)")
      end
    end
  end
end
