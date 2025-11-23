require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::Directives do
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

    context "parses identifiers from iso-directives.txt" do
      let(:examples_file) { "iso/iso-directives.txt" }

      it_behaves_like "parse identifiers from file"
    end
  end

  # Test basic identifiers
  context "basic identifiers" do
    # Test normal dated directives
    context "dated directives" do
      describe "ISO DIR 1:2022" do
        subject { "ISO DIR 1:2022" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:doc:iso:dir:1:2022" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses part" do
          expect(parsed.part.value).to be_nil
        end

        it "parses date" do
          expect(parsed.date.date.year).to eq("2022")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("dir")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("DIR")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/IEC DIR 1:2022" do
        subject { "ISO/IEC DIR 1:2022" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:doc:iso-iec:dir:1:2022" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses date" do
          expect(parsed.date.date.year).to eq("2022")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("dir")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("DIR")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end

    # Test normal undated directives
    context "undated directives" do
      describe "ISO DIR 1" do
        subject { "ISO DIR 1" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:doc:iso:dir:1" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses part" do
          expect(parsed.part.value).to be_nil
        end

        it "parses date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("dir")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("DIR")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/IEC DIR 1" do
        subject { "ISO/IEC DIR 1" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:doc:iso-iec:dir:1" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("dir")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("DIR")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/IEC DIR 2" do
        subject { "ISO/IEC DIR 2" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:doc:iso-iec:dir:2" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("2")
        end

        it "parses date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("dir")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("DIR")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end

  # Test format normalization
  context "format normalization" do
    describe "ISO/IEC Directives Part 1" do
      subject { "ISO/IEC Directives Part 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/IEC DIR 1" }
      let(:urn) { "urn:iso:doc:iso-iec:dir:1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date).to be_nil
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/IEC Directives, Part 1:2022" do
      subject { "ISO/IEC Directives, Part 1:2022" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/IEC DIR 1:2022" }
      let(:urn) { "urn:iso:doc:iso-iec:dir:1:2022" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.date.year).to eq("2022")
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test JTC variations
  context "JTC variations" do
    describe "ISO/IEC JTC 1 DIR" do
      subject { "ISO/IEC JTC 1 DIR" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:doc:iso-iec:jtc:1:dir" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test organization-specific variations
  context "organization-specific variations" do
    describe "ISO/IEC DIR 2 ISO" do
      subject { "ISO/IEC DIR 2 ISO" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:doc:iso-iec:dir:2:iso" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/IEC DIR 2 IEC" do
      subject { "ISO/IEC DIR 2 IEC" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:doc:iso-iec:dir:2:iec" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/IEC DIR 2 IEC:2022" do
      subject { "ISO/IEC DIR 2 IEC:2022" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:doc:iso-iec:dir:2:iec:2022" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("2")
      end

      it "parses date" do
        expect(parsed.date.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test combined identifiers (now supported!)
  context "combined identifiers" do
    describe "ISO/IEC DIR 1:2022 + IEC SUP:2022" do
      subject { "ISO/IEC DIR 1:2022 + IEC SUP:2022" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:doc:iso-iec:dir:1:2022:iec:sup:2022" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test combined identifiers (now supported!)
  context "combined identifiers" do
    describe "ISO/IEC DIR 1:2022 + IEC SUP:2022" do
      subject { "ISO/IEC DIR 1:2022 + IEC SUP:2022" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:doc:iso-iec:dir:1:2022:iec:sup:2022" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("dir")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("DIR")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end
end
