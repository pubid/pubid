require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::Data do
  subject { described_class }

  # Note: No sweep test - fixture file iso/iso-data.txt does not exist
  # The identifier-specific tests below provide adequate coverage

  # Test basic identifiers
  context "basic identifiers" do
    # Test normal dated data
    context "dated data" do
      describe "ISO/DATA 1:1978" do
        subject { "ISO/DATA 1:1978" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso:data:1" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses part" do
          expect(parsed.part).to be_nil
        end

        it "parses date" do
          expect(parsed.date.year).to eq("1978")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("data")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides type abbreviation" do
          expect(parsed.type.abbr).to eq("DATA")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end

    # Test normal undated data
    context "undated data" do
      describe "ISO/DATA 9" do
        subject { "ISO/DATA 9" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso:data:9" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("9")
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
          expect(parsed.typed_stage.type_code).to eq("data")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides type abbreviation" do
          expect(parsed.type.abbr).to eq("DATA")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end
end
