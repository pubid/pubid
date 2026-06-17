require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::TechnicalReport do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC TR 62048:2014" do
      subject { "IEC TR 62048:2014" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62048")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("tr")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation TR" do
        expect(parsed.typed_stage.abbreviation).to eq("TR")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC TR 62048" do
      subject { "IEC TR 62048" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62048")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("tr")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test normal identifier with part
  context "parse normal identifier with part" do
    describe "IEC TR 61850-90-12:2015" do
      subject { "IEC TR 61850-90-12:2015" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("61850")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("90")
      end

      it "parses subpart" do
        expect(parsed.subpart.value).to eq("12")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2015")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("tr")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC TR 13066-1:2011" do
      subject { "ISO/IEC TR 13066-1:2011" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("13066")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2011")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("tr")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test draft stage
  context "draft technical report" do
    describe "IEC/DTR 62048" do
      subject { "IEC/DTR 62048" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62048")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "provides typed_stage with abbreviation DTR" do
        expect(parsed.typed_stage.abbreviation).to eq("DTR")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC DTR 62048")
      end
    end
  end

  # Test dated draft
  context "dated draft technical report" do
    describe "IEC/DTR 62048:2014" do
      subject { "IEC/DTR 62048:2014" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62048")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC DTR 62048:2014")
      end
    end
  end

  # Test draft with part
  context "draft technical report with part" do
    describe "IEC/DTR 61850-90-12:2015" do
      subject { "IEC/DTR 61850-90-12:2015" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("61850")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("90")
      end

      it "parses subpart" do
        expect(parsed.subpart.value).to eq("12")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2015")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC DTR 61850-90-12:2015")
      end
    end
  end

  # Test early-stage typed stages from Excel reference
  context "early-stage typed stages" do
    context "NP TR stage" do
      describe "IEC/NP TR 62048" do
        subject { "IEC/NP TR 62048" }

        let(:parsed) { described_class.parse(subject) }

        it "parses publisher" do
          expect(parsed.publisher.body).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("62048")
        end

        it "parses stage" do
          expect(parsed.stage.stage_code).to eq("np")
        end

        it "provides type code" do
          expect(parsed.type.type_code).to eq("tr")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("IEC NP TR 62048")
        end
      end
    end

    context "WD TR stage" do
      describe "IEC/WD TR 62048" do
        subject { "IEC/WD TR 62048" }

        let(:parsed) { described_class.parse(subject) }

        it "parses publisher" do
          expect(parsed.publisher.body).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("62048")
        end

        it "parses stage" do
          expect(parsed.stage.stage_code).to eq("wd")
        end

        it "provides type code" do
          expect(parsed.type.type_code).to eq("tr")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("IEC WD TR 62048")
        end
      end
    end

    context "CD TR stage" do
      describe "IEC/CD TR 62048" do
        subject { "IEC/CD TR 62048" }

        let(:parsed) { described_class.parse(subject) }

        it "parses publisher" do
          expect(parsed.publisher.body).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("62048")
        end

        it "parses stage" do
          expect(parsed.stage.stage_code).to eq("cd")
        end

        it "provides type code" do
          expect(parsed.type.type_code).to eq("tr")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("IEC CD TR 62048")
        end
      end
    end
  end
end
