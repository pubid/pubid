require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::Addendum do
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

    context "parses identifiers from iso-add.txt" do
      let(:examples_file) { "iso/iso-add.txt" }

      it_behaves_like "parse identifiers from file"
    end
  end

  # Test basic addendum identifiers
  context "basic addendum identifiers" do
    describe "ISO/R 947:1969/Add 1:1969" do
      subject { "ISO/R 947:1969/Add 1:1969" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:r:947:sup:1969:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("947")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1969")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("rec")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date.year).to eq("1969")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/R 194:1969/Add 4" do
      subject { "ISO/R 194:1969/Add 4" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:r:194:sup:4:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("194")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1969")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("rec")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("4")
      end

      it "parses addendum date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 1942:1983/Add 1:1983" do
      subject { "ISO 1942:1983/Add 1:1983" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:1942:sup:1983:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("1942")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1983")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("is")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date.year).to eq("1983")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/TR 8373:1988/Add 1:1990" do
      subject { "ISO/TR 8373:1988/Add 1:1990" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:tr:8373:sup:1990:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("8373")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1988")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("tr")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date.year).to eq("1990")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test legacy format normalization
  context "legacy format normalization" do
    describe "ISO 4037-1979/Add. 1-1983(F)" do
      subject { "ISO 4037-1979/Add. 1-1983(F)" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO 4037:1979/Add 1:1983(fr)" }
      let(:urn) { "urn:iso:std:iso:4037:sup:1983:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("4037")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1979")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("is")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date.year).to eq("1983")
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/R 91-1970 — Addendum 1" do
      subject { "ISO/R 91-1970 — Addendum 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/R 91:1970/Add 1" }
      let(:urn) { "urn:iso:std:iso:r:91:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("91")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1970")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("rec")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date).to be_nil
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/R 91:1970/ADD 1:1975" do
      subject { "ISO/R 91:1970/ADD 1:1975" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/R 91:1970/Add 1:1975" }
      let(:urn) { "urn:iso:std:iso:r:91:sup:1975:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("91")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1970")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("rec")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date.year).to eq("1975")
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("Add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test draft addenda stages
  context "draft addenda stages" do
    describe "ISO 2631/DAD 1" do
      subject { "ISO 2631/DAD 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:2631:stage-draft:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("2631")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date).to be_nil
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date).to be_nil
      end

      it "parses stage" do
        expect(parsed.typed_stage.stage_code).to eq("dad")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 2553/DAD 1:1987" do
      subject { "ISO 2553/DAD 1:1987" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:2553:stage-draft:sup:1987:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("2553")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date).to be_nil
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses addendum date" do
        expect(parsed.date.year).to eq("1987")
      end

      it "parses stage" do
        expect(parsed.typed_stage.stage_code).to eq("dad")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/DIS 1151-1/DAD 2" do
      subject { "ISO/DIS 1151-1/DAD 2" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:1151:-1:stage-draft:stage-draft:sup:2:v1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("1151")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.value).to eq("1")
      end

      it "parses base identifier stage" do
        expect(parsed.base_identifier.typed_stage.stage_code).to eq("dis")
      end

      it "parses addendum number" do
        expect(parsed.number.value).to eq("2")
      end

      it "parses addendum date" do
        expect(parsed.date).to be_nil
      end

      it "parses stage" do
        expect(parsed.typed_stage.stage_code).to eq("dad")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("add")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end
end
