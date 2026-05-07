require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::Corrigendum do
  subject { described_class }

  # Test published corrigendum
  context "parse published corrigendum" do
    describe "IEC 60038:2009/Cor 1:2011" do
      subject { "IEC 60038:2009/Cor 1:2011" }

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

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("1")
      end

      it "parses corrigendum date" do
        expect(parsed.date.year).to eq("2011")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("cor")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC 60038:2009/COR1:2011")
      end
    end
  end

  # Test with part in base identifier
  context "corrigendum to standard with part" do
    describe "IEC 60038-1:2009/Cor 2:2012" do
      subject { "IEC 60038-1:2009/Cor 2:2012" }

      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.number).to eq("1")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2009")
      end

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("2")
      end

      it "parses corrigendum date" do
        expect(parsed.date.year).to eq("2012")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC 60038-1:2009/COR2:2012")
      end
    end
  end

  # Test ISO/IEC copublished corrigendum
  context "parse ISO/IEC corrigendum" do
    describe "ISO/IEC 17025:2017/Cor 1:2020" do
      subject { "ISO/IEC 17025:2017/Cor 1:2020" }

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

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("1")
      end

      it "parses corrigendum date" do
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ISO/IEC 17025:2017/COR1:2020")
      end
    end
  end

  # Test draft corrigendum (DCOR)
  context "parse draft corrigendum" do
    describe "IEC/DCOR 60038-1" do
      subject { "IEC/DCOR 60038-1" }

      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("1")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("cor")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("dcor")
      end

      it "provides typed_stage with canonical abbreviation DCOR" do
        expect(parsed.typed_stage.canonical_abbreviation).to eq("DCOR")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test final draft corrigendum (FDCOR)
  context "parse final draft corrigendum" do
    describe "IEC/FDCOR 60038-1" do
      subject { "IEC/FDCOR 60038-1" }

      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("1")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("cor")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("fdcor")
      end

      it "provides typed_stage with canonical abbreviation FDCOR" do
        expect(parsed.typed_stage.canonical_abbreviation).to eq("FDCOR")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test committee draft corrigendum (CDCor)
  context "parse committee draft corrigendum" do
    describe "IEC/CDCor 60038-1" do
      subject { "IEC/CDCor 60038-1" }

      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("1")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("cor")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("cd")
      end

      it "provides typed_stage with canonical abbreviation CDCor" do
        expect(parsed.typed_stage.canonical_abbreviation).to eq("CDCor")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test uppercase COR variant
  context "uppercase COR abbreviation" do
    describe "IEC 60038:2009/COR 1:2011" do
      subject { "IEC 60038:2009/COR 1:2011" }

      let(:parsed) { described_class.parse(subject) }

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60038")
      end

      it "parses corrigendum number" do
        expect(parsed.number.number).to eq("1")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("cor")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC 60038:2009/COR1:2011")
      end
    end
  end
end
