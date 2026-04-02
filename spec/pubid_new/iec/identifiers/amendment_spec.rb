require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::Amendment do
  subject { described_class }

  context "parse amendment identifier" do
    describe "IEC 60038:2009/Amd 1:2011" do
      subject { "IEC 60038:2009/Amd 1:2011" }
      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2009")
      end

      it "parses amendment number" do
        expect(parsed.number.number).to eq("1")
      end

      it "parses amendment date" do
        expect(parsed.date.year).to eq("2011")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("amd")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC 60038:2009/AMD1:2011")
      end
    end
  end

  context "parse draft amendment" do
    describe "IEC/FDAM 60038-1" do
      subject { "IEC/FDAM 60038-1" }
      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses amendment number" do
        expect(parsed.number.number).to eq("1")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("amd")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("fdamd")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "parse ISO/IEC amendment" do
    describe "ISO/IEC 17025:2017/Amd 1:2020" do
      subject { "ISO/IEC 17025:2017/Amd 1:2020" }
      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("ISO")
      end

      it "parses base identifier copublisher" do
        expect(parsed.base_identifier.copublishers.first.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("17025")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2017")
      end

      it "parses amendment number" do
        expect(parsed.number.number).to eq("1")
      end

      it "parses amendment date" do
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ISO/IEC 17025:2017/AMD1:2020")
      end
    end
  end
end
