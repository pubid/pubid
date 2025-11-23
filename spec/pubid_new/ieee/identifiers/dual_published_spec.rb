require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Ieee::Identifiers::DualPublished do
  describe ".parse" do
    context "dual identifiers separated by 'and'" do
      it "parses ANSI and IEEE joint publication" do
        id = PubidNew::Ieee.parse("ANSI C37.61-1973 and IEEE Std 321-1973")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::DualPublished)
        expect(id.first_identifier.publisher).to eq("ANSI")
        expect(id.second_identifier.publisher).to eq("IEEE")
        expect(id.to_s).to eq("ANSI C37.61-1973 and IEEE Std 321-1973")
      end

      it "parses IEC and IEEE joint publication" do
        id = PubidNew::Ieee.parse("IEC 60255-24 Edition 2.0 2013-04 and IEEE Std C37.111-2013")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::DualPublished)
        expect(id.first_identifier.publisher).to eq("IEC")
        expect(id.second_identifier.publisher).to eq("IEEE")
        expect(id.to_s).to eq("IEC 60255-24 Edition 2.0 2013-04 and IEEE Std C37.111-2013")
      end
    end

    context "space-separated dual identifiers" do
      it "parses IEC and IEEE space-separated publication" do
        id = PubidNew::Ieee.parse("IEC 62014-5 IEEE Std 1734-2011")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::DualPublished)
        expect(id.first_identifier.publisher).to eq("IEC")
        expect(id.second_identifier.publisher).to eq("IEEE")
        expect(id.to_s).to eq("IEC 62014-5 and IEEE Std 1734-2011")
      end

      it "parses ANSI and IEEE space-separated publication" do
        id = PubidNew::Ieee.parse("ANSI C37.61-1973 IEEE Std 321-1973")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::DualPublished)
        expect(id.first_identifier.publisher).to eq("ANSI")
        expect(id.second_identifier.publisher).to eq("IEEE")
        expect(id.to_s).to eq("ANSI C37.61-1973 and IEEE Std 321-1973")
      end
    end

    context "distinguishing from co-published" do
      it "does not treat IEC/IEEE as dual published" do
        id = PubidNew::Ieee.parse("IEC/IEEE 62582-1 Edition 1.0 2011-05")
        expect(id).not_to be_a(PubidNew::Ieee::Identifiers::DualPublished)
      end

      it "does not treat IEEE/IEC copublisher as dual published" do
        id = PubidNew::Ieee.parse("IEEE/IEC Std 62582-1-2011")
        expect(id).not_to be_a(PubidNew::Ieee::Identifiers::DualPublished)
        expect(id).to be_a(PubidNew::Ieee::Identifiers::Base)
      end
    end

    context "publisher method" do
      it "returns array of publishers for dual published" do
        id = PubidNew::Ieee.parse("IEC 62014-5 IEEE Std 1734-2011")
        expect(id.publisher).to eq(["IEC", "IEEE"])
      end
    end

    context "round-trip parsing" do
      it "maintains both identifiers correctly" do
        input = "ANSI C37.61-1973 and IEEE Std 321-1973"
        id = PubidNew::Ieee.parse(input)
        expect(id.to_s).to eq(input)
      end

      it "normalizes space-separated to 'and' format" do
        id = PubidNew::Ieee.parse("IEC 62014-5 IEEE Std 1734-2011")
        expect(id.to_s).to eq("IEC 62014-5 and IEEE Std 1734-2011")
      end
    end
  end
end