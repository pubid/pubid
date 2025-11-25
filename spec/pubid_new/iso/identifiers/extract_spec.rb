require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::Extract do
  subject { described_class }

  xdescribe "parse identifiers from examples" do
    shared_examples "parse identifiers from file" do
      it "parse identifiers from file" do
        f = open("spec/fixtures/#{examples_file}")
        f.readlines.each do |pub_id|
          next if pub_id.match?("^#")

          expect(subject).to parse(pub_id.split("#").first.strip.chomp)
        end
      end
    end

    context "parses identifiers from iso-extract.txt" do
      let(:examples_file) { "iso/iso-extract.txt" }

      it_behaves_like "parse identifiers from file"
    end
  end

  # Test basic extract identifiers
  context "basic extract identifiers" do
    # Test normal extract with base identifier
    context "extract with base identifier" do
      describe "ISO 1101:1983/Ext 1:1983" do
        subject { "ISO 1101:1983/Ext 1:1983" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso:1101:ext:1983:v1" }

        it "parses publisher" do
          expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
        end

        it "parses base identifier number" do
          expect(parsed.base_identifier.number.value).to eq("1101")
        end

        it "parses base identifier date" do
          expect(parsed.base_identifier.date.year).to eq("1983")
        end

        it "parses extract number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses extract date" do
          expect(parsed.date.year).to eq("1983")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("ext")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("Ext")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end
end
