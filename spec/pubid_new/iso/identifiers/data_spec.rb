require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::Data do
  subject { described_class }

  xdescribe "parse identifiers from examples" do
    shared_examples "parse identifiers from file" do
      it "parse identifiers from file" do
        f = open("spec/fixtures/#{examples_file}")
        f.readlines.each do |pub_id|
          next if pub_id.match?("^#")

          expect(PubidNew::Iso.parse(pub_id.split("#").first.strip.chomp)).to be_a(described_class)
        end
      end
    end

    context "parses identifiers from iso-data.txt" do
      let(:examples_file) { "iso/iso-data.txt" }

      it_behaves_like "parse identifiers from file"
    end
  end

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

        xit "provides type code" do
          # TODO: V2 Data uses `type` attribute, not `typed_stage`
          # V1 API: .type.type_code
          # V2 has different architecture for type information
          expect(parsed.typed_stage.type_code).to eq("data")
        end

        xit "provides stage code" do
          # TODO: V2 Data uses `type` attribute, not `typed_stage`
          # V1 API: .stage.stage_code
          # V2 has different architecture for stage information
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides type abbreviation" do
          expect(parsed.type.abbr).to eq("DATA")
        end

        xit "generates urn" do
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

        xit "provides type code" do
          # TODO: V2 Data uses `type` attribute, not `typed_stage`
          # V1 API: .type.type_code
          # V2 has different architecture for type information
          expect(parsed.typed_stage.type_code).to eq("data")
        end

        xit "provides stage code" do
          # TODO: V2 Data uses `type` attribute, not `typed_stage`
          # V1 API: .stage.stage_code
          # V2 has different architecture for stage information
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides type abbreviation" do
          expect(parsed.type.abbr).to eq("DATA")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end
end
