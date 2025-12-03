require "spec_helper"

RSpec.describe PubidNew::Cen::Parser do
  subject { described_class.new }

  describe "#parse" do
    context "basic EN identifiers" do
      it "parses EN without date" do
        result = subject.parse("EN 10077-1")
        expect(result[:publisher]).to eq("EN")
        expect(result[:number]).to eq("10077")
        expect(result[:parts]).to be_an(Array)
        expect(result[:parts].first[:part]).to eq("1")
      end

      it "parses EN with date" do
        result = subject.parse("EN 10077-1:2006")
        expect(result[:publisher]).to eq("EN")
        expect(result[:number]).to eq("10077")
        expect(result[:parts]).to be_an(Array)
        expect(result[:year]).to eq("2006")
      end

      it "parses multi-part numbers" do
        result = subject.parse("EN 29110-5-1-1:2015")
        expect(result[:number]).to eq("29110")
        expect(result[:parts]).to be_an(Array)
        expect(result[:parts].first[:part]).to eq("5-1-1")
      end
    end

    context "stage prefixes" do
      it "parses prEN (proposal)" do
        result = subject.parse("prEN 15316-1:2020")
        expect(result[:type_with_stage]).to eq("prEN")
        expect(result[:number]).to eq("15316")
        expect(result[:parts].first[:part]).to eq("1")
      end

      it "parses FprEN (final proposal)" do
        result = subject.parse("FprEN 987:2018")
        expect(result[:type_with_stage]).to eq("FprEN")
        expect(result[:number]).to eq("987")
      end
    end

    context "typed documents" do
      it "parses CEN TS" do
        result = subject.parse("CEN TS 1234:2010")
        expect(result[:publisher]).to eq("CEN")
        expect(result[:type]).to eq("TS")
        expect(result[:number]).to eq("1234")
      end

      it "parses CEN TR" do
        result = subject.parse("CEN TR 456:2015")
        expect(result[:publisher]).to eq("CEN")
        expect(result[:type]).to eq("TR")
      end

      it "parses CWA" do
        result = subject.parse("CWA 17145-2:2017")
        expect(result[:publisher]).to eq("CWA")
        expect(result[:number]).to eq("17145")
        expect(result[:parts].first[:part]).to eq("2")
      end
    end

    context "copublished documents" do
      it "parses EN/CLC" do
        result = subject.parse("EN/CLC TS 50131-1:2006")
        expect(result[:publisher]).to eq("EN")
        expect(result[:copublisher]).to eq("CLC")
        expect(result[:type]).to eq("TS")
      end
    end

    context "bundled identifiers" do
      it "parses single bundled corrigendum" do
        result = subject.parse("EN 10077-1:2006+AC:2009")
        expect(result[:publisher]).to eq("EN")
        expect(result[:number]).to eq("10077")
        expect(result[:supplements]).to be_an(Array)
        expect(result[:supplements].length).to eq(1)
      end

      it "parses multiple bundled supplements" do
        result = subject.parse("EN 10077-1:2006+AC:2009+AC2:2009")
        expect(result[:supplements].length).to eq(2)
      end
    end

    context "slash supplements" do
      it "parses amendment" do
        result = subject.parse("EN 1234:1999/A1:2005")
        expect(result[:publisher]).to eq("EN")
        expect(result[:number]).to eq("1234")
        expect(result[:supplements]).to be_an(Array)
        expect(result[:supplements].first[:supplement][:amd_number]).to eq("1")
      end

      it "parses corrigendum" do
        result = subject.parse("EN 1234:1999/AC1:2005")
        expect(result[:publisher]).to eq("EN")
        expect(result[:number]).to eq("1234")
        expect(result[:supplements]).to be_an(Array)
        expect(result[:supplements].first[:supplement][:cor_number]).to eq("1")
      end
    end
  end
end