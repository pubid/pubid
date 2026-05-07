require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::InternationalStandard do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC 60038:2009" do
      subject { "IEC 60038:2009" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("60038")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2009")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("is")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation of blank for :is" do
        expect(parsed.typed_stage.abbreviation).to eq("")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC 60038" do
      subject { "IEC 60038" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("60038")
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
        expect(parsed.type.type_code).to eq("is")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation of blank for :is" do
        expect(parsed.typed_stage.abbreviation).to eq("")
      end
    end
  end

  # Test normal identifier with part
  context "parse normal identifier with part" do
    describe "IEC 60038-1:2009" do
      subject { "IEC 60038-1:2009" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("60038")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2009")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("is")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation of blank for :is" do
        expect(parsed.typed_stage.abbreviation).to eq("")
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC 17025:2017" do
      subject { "ISO/IEC 17025:2017" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("17025")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2017")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("is")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test stages
  context "stages" do
    context "stage without iteration" do
      context "preliminary" do
        # NOTE: Parser doesn't support PWI (preliminary work item) stage yet
        describe "IEC/PWI 60038" do
          subject { "IEC/PWI 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("pwi")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "committee draft" do
        describe "IEC/CD 60038" do
          subject { "IEC/CD 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("cd")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "committee draft for vote" do
        describe "IEC/CDV 60038" do
          subject { "IEC/CDV 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("cdv")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "new proposal" do
        describe "IEC/NP 60038" do
          subject { "IEC/NP 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("np")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "approved new work" do
        describe "IEC/ANW 60038" do
          subject { "IEC/ANW 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("anw")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "working draft" do
        describe "IEC/WD 60038" do
          subject { "IEC/WD 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("wd")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "final draft" do
        describe "IEC/FDIS 60038" do
          subject { "IEC/FDIS 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("fdis")
          end

          it "round-trips" do
            expect(parsed.to_s).to eq(subject)
          end
        end
      end

      context "proof" do
        describe "IEC/PRF 60038" do
          subject { "IEC/PRF 60038" }

          let(:parsed) { described_class.parse(subject) }

          it "parses publisher" do
            expect(parsed.publisher.body).to eq("IEC")
          end

          it "parses number" do
            expect(parsed.number.number).to eq("60038")
          end

          it "parses stage" do
            expect(parsed.stage.stage_code).to eq("fdis")
          end

          it "provides typed_stage with PRF abbreviation" do
            expect(parsed.typed_stage.abbr).to include("PRF")
          end

          it "round-trips to canonical FDIS form" do
            expect(parsed.to_s).to eq("IEC/FDIS 60038")
          end
        end
      end
    end
  end
end
