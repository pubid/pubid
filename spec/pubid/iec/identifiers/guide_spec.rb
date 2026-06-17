require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::Guide do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC Guide 51:2014" do
      subject { "IEC Guide 51:2014" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("51")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC GUIDE 51:2014")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("guide")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation GUIDE" do
        expect(parsed.typed_stage.abbreviation).to eq("GUIDE")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC Guide 104" do
      subject { "IEC Guide 104" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("104")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC GUIDE 104")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("guide")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test identifier with part
  context "parse identifier with part" do
    describe "IEC Guide 115-1:2021" do
      subject { "IEC Guide 115-1:2021" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("115")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2021")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC GUIDE 115-1:2021")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("guide")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC Guide 51:2014" do
      subject { "ISO/IEC Guide 51:2014" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("51")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ISO/IEC GUIDE 51:2014")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("guide")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test draft stage
  context "draft guide" do
    describe "IEC DGuide 104" do
      subject { "IEC DGuide 104" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("104")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "provides typed_stage with abbreviation DGuide" do
        expect(parsed.typed_stage.abbreviation).to eq("DGuide")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test final draft stage
  context "final draft guide" do
    describe "IEC FDGuide 104" do
      subject { "IEC FDGuide 104" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("104")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("final_draft")
      end

      it "provides typed_stage with abbreviation FDGuide" do
        expect(parsed.typed_stage.abbreviation).to eq("FDGuide")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test dated draft
  context "dated draft guide" do
    describe "IEC DGuide 104:2020" do
      subject { "IEC DGuide 104:2020" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("104")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2020")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test uppercase GUIDE variant
  context "uppercase GUIDE abbreviation" do
    describe "IEC GUIDE 108:2006" do
      subject { "IEC GUIDE 108:2006" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("108")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2006")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("guide")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test early-stage typed stages from Excel reference
  context "early-stage typed stages" do
    context "CD Guide stage" do
      describe "IEC/CD Guide 104" do
        subject { "IEC/CD Guide 104" }

        let(:parsed) { described_class.parse(subject) }

        it "parses publisher" do
          expect(parsed.publisher.body).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("104")
        end

        it "parses stage" do
          expect(parsed.stage.stage_code).to eq("cd")
        end

        it "provides type code" do
          expect(parsed.type.type_code).to eq("guide")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("IEC CD Guide 104")
        end
      end
    end

    context "WD Guide stage" do
      describe "IEC/WD Guide 104" do
        subject { "IEC/WD Guide 104" }

        let(:parsed) { described_class.parse(subject) }

        it "parses publisher" do
          expect(parsed.publisher.body).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("104")
        end

        it "parses stage" do
          expect(parsed.stage.stage_code).to eq("wd")
        end

        it "provides type code" do
          expect(parsed.type.type_code).to eq("guide")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("IEC WD Guide 104")
        end
      end
    end

    context "NP Guide stage" do
      describe "IEC/NP Guide 104" do
        subject { "IEC/NP Guide 104" }

        let(:parsed) { described_class.parse(subject) }

        it "parses publisher" do
          expect(parsed.publisher.body).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("104")
        end

        it "parses stage" do
          expect(parsed.stage.stage_code).to eq("np")
        end

        it "provides type code" do
          expect(parsed.type.type_code).to eq("guide")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("IEC NP Guide 104")
        end
      end
    end
  end
end
