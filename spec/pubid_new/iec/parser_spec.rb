require "spec_helper"

RSpec.describe PubidNew::Iec::Parser do
  subject { described_class.new }

  describe "#parse" do
    context "basic IEC identifier" do
      it "parses IEC 60038:2009" do
        result = subject.parse("IEC 60038:2009")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("IEC")
        expect(result[:number_with_part]).to eq("60038")
        expect(result[:date]).to eq("2009")
      end

      it "parses IEC 60038" do
        result = subject.parse("IEC 60038")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("IEC")
        expect(result[:number_with_part]).to eq("60038")
      end

      it "parses IEC 60038-1:2009" do
        result = subject.parse("IEC 60038-1:2009")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("IEC")
        expect(result[:number_with_part]).to eq("60038-1")
        expect(result[:date]).to eq("2009")
      end
    end

    context "ISO/IEC joint identifier" do
      it "parses ISO/IEC 17025:2017" do
        result = subject.parse("ISO/IEC 17025:2017")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("ISO")
        expect(result[:copublishers]).to be_an(Array)
        expect(result[:copublishers].first[:copublisher]).to eq("IEC")
        expect(result[:number_with_part]).to eq("17025")
        expect(result[:date]).to eq("2017")
      end
    end

    context "staged identifiers" do
      it "parses IEC/CD 60038" do
        result = subject.parse("IEC/CD 60038")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("IEC")
        expect(result[:type_with_stage]).to eq("CD")
        expect(result[:number_with_part]).to eq("60038")
      end

      it "parses IEC/FDIS 60038" do
        result = subject.parse("IEC/FDIS 60038")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("IEC")
        expect(result[:type_with_stage]).to eq("FDIS")
        expect(result[:number_with_part]).to eq("60038")
      end

      it "parses IEC/TS 60038" do
        result = subject.parse("IEC/TS 60038")
        expect(result).to be_a(Hash)
        expect(result[:publisher]).to eq("IEC")
        expect(result[:type_with_stage]).to eq("TS")
        expect(result[:number_with_part]).to eq("60038")
      end
    end

    context "supplement identifiers" do
      it "parses IEC 60038:2009/Amd 1:2011" do
        result = subject.parse("IEC 60038:2009/Amd 1:2011")
        expect(result).to be_a(Hash)
        expect(result[:base_identifier]).to be_a(Hash)
        expect(result[:base_identifier][:publisher]).to eq("IEC")
        expect(result[:base_identifier][:number_with_part]).to eq("60038")
        expect(result[:base_identifier][:date]).to eq("2009")
        expect(result[:type_with_stage]).to eq("Amd")
        expect(result[:number_with_part]).to eq("1")
        expect(result[:date]).to eq("2011")
      end

      it "parses IEC 60038:2009/Cor 1:2012" do
        result = subject.parse("IEC 60038:2009/Cor 1:2012")
        expect(result).to be_a(Hash)
        expect(result[:base_identifier]).to be_a(Hash)
        expect(result[:type_with_stage]).to eq("Cor")
        expect(result[:number_with_part]).to eq("1")
        expect(result[:date]).to eq("2012")
      end
    end
  end
end