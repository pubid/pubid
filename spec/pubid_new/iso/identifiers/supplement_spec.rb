require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::Supplement do
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

    context "parses identifiers from iso-sup.txt" do
      let(:examples_file) { "iso/iso-sup.txt" }

      it_behaves_like "parse identifiers from file"
    end
  end

  # Test basic supplement identifiers
  context "basic supplement identifiers" do
    describe "ISO/IEC Guide 98-3:2008/Suppl 1:2008" do
      subject { "ISO/IEC Guide 98-3:2008/Suppl 1:2008" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso-iec:guide:98:-3:sup:2008:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.base_identifier.publisher.copublisher.first).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("98")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.value).to eq("3")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2008")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("guide")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date.year).to eq("2008")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 123:1999/Suppl 1" do
      subject { "ISO 123:1999/Suppl 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:123:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("123")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1999")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test legacy format normalization
  context "legacy format normalization" do
    describe "ISO/IEC Guide 98-3/Suppl.1:2008" do
      subject { "ISO/IEC Guide 98-3/Suppl.1:2008" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/IEC Guide 98-3/Suppl 1:2008" }
      let(:urn) { "urn:iso:std:iso-iec:guide:98:-3:sup:2008:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.base_identifier.publisher.copublisher.first).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("98")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.value).to eq("3")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("guide")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date.year).to eq("2008")
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/IEC Guide 98-3:2008/Suppl.1:2008(en)" do
      subject { "ISO/IEC Guide 98-3:2008/Suppl.1:2008(en)" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/IEC Guide 98-3:2008/Suppl 1:2008(en)" }
      let(:urn) { "urn:iso:std:iso-iec:guide:98:-3:sup:2008:v1:en" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.base_identifier.publisher.copublisher.first).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("98")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.value).to eq("3")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2008")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("guide")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date.year).to eq("2008")
      end

      it "parses languages" do
        expect(parsed.languages.map(&:code)).to eq(%w[en])
      end

      it "normalizes format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test supplement stages
  context "supplement stages" do
    context "proposal" do
      describe "ISO/IEC Guide 98-3/NP Suppl 2" do
        subject { "ISO/IEC Guide 98-3/NP Suppl 2" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:guide:98:-3:stage-00.00:sup:2:v1" }

        it "parses publisher" do
          expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.base_identifier.publisher.copublisher.first).to eq("IEC")
        end

        it "parses base identifier number" do
          expect(parsed.base_identifier.number.value).to eq("98")
        end

        it "parses base identifier part" do
          expect(parsed.base_identifier.part.value).to eq("3")
        end

        it "parses base identifier type" do
          expect(parsed.base_identifier.typed_stage.type_code).to eq("guide")
        end

        it "parses supplement number" do
          expect(parsed.number.value).to eq("2")
        end

        it "parses supplement date" do
          expect(parsed.date).to be_nil
        end

        it "parses stage" do
          pending 'typed_stage removed in V2 architecture'
          expect(parsed.typed_stage.stage_code).to eq("np")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          pending 'typed_stage removed in V2 architecture'
          expect(parsed.typed_stage.type_code).to eq("suppl")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end

    context "draft supplement" do
      describe "ISO Guide 98:1995/DSuppl 1.2" do
        subject { "ISO Guide 98:1995/DSuppl 1.2" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:pubid) { "ISO/Guide 98:1995/DSuppl 1.2" }
        let(:urn) { "urn:iso:std:iso:guide:98:stage-draft:sup:1:v1" }

        it "parses publisher" do
          expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
        end

        it "parses base identifier number" do
          expect(parsed.base_identifier.number.value).to eq("98")
        end

        it "parses base identifier date" do
          expect(parsed.base_identifier.date.year).to eq("1995")
        end

        it "parses base identifier type" do
          expect(parsed.base_identifier.typed_stage.type_code).to eq("guide")
        end

        it "parses supplement number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses supplement date" do
          expect(parsed.date).to be_nil
        end

        it "parses stage" do
          pending 'typed_stage removed in V2 architecture'
          expect(parsed.typed_stage.stage_code).to eq("dsuppl")
        end

        it "parses iteration" do
          expect(parsed.stage_iteration.value).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(pubid)
        end

        it "provides type code" do
          pending 'typed_stage removed in V2 architecture'
          expect(parsed.typed_stage.type_code).to eq("suppl")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/IEC NP Guide 98:1995/DSuppl 1.2" do
        subject { "ISO/IEC NP Guide 98:1995/DSuppl 1.2" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) do
          "urn:iso:std:iso-iec:guide:98:stage-draft:stage-draft:sup:1:v1"
        end

        it "parses publisher" do
          expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.base_identifier.publisher.copublisher.first).to eq("IEC")
        end

        it "parses base identifier number" do
          expect(parsed.base_identifier.number.value).to eq("98")
        end

        it "parses base identifier date" do
          expect(parsed.base_identifier.date.year).to eq("1995")
        end

        it "parses base identifier type" do
          expect(parsed.base_identifier.typed_stage.type_code).to eq("guide")
        end

        it "parses base identifier stage" do
          expect(parsed.base_identifier.typed_stage.stage_code).to eq("np")
        end

        it "parses supplement number" do
          expect(parsed.number.value).to eq("1")
        end

        it "parses supplement date" do
          expect(parsed.date).to be_nil
        end

        it "parses stage" do
          pending 'typed_stage removed in V2 architecture'
          expect(parsed.typed_stage.stage_code).to eq("dsuppl")
        end

        it "parses iteration" do
          expect(parsed.stage_iteration.value).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          pending 'typed_stage removed in V2 architecture'
          expect(parsed.typed_stage.type_code).to eq("suppl")
        end

        xit "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end

  # Test supplement without number
  xcontext "supplement without number" do
    describe "ISO 3758:1991/Suppl:1993" do
      subject { "ISO 3758:1991/Suppl:1993" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:3758:sup:1993" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("3758")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("1991")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to be_nil
      end

      it "parses supplement date" do
        expect(parsed.date.year).to eq("1993")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test supplement with different base types
  context "supplement with different base types" do
    describe "ISO/TR 10000:2000/Suppl 1:2005" do
      subject { "ISO/TR 10000:2000/Suppl 1:2005" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:tr:10000:sup:2005:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("10000")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2000")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("tr")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date.year).to eq("2005")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 14000:2015/Suppl 1:2020" do
      subject { "ISO 14000:2015/Suppl 1:2020" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:14000:sup:2020:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("14000")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2015")
      end

      it "parses base identifier type" do
        expect(parsed.base_identifier.typed_stage.type_code).to eq("is")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      it "provides stage code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.abbr.first).to eq("Suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end

  # Test supplement stage variations
  context "supplement stage variations" do
    describe "ISO 10000:2020/WD Suppl 1" do
      subject { "ISO 10000:2020/WD Suppl 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:10000:stage-20.20:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("10000")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2020")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date).to be_nil
      end

      it "parses stage" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("wd")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 10000:2020/CD Suppl 1" do
      subject { "ISO 10000:2020/CD Suppl 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:10000:stage-30.00:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("10000")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2020")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date).to be_nil
      end

      it "parses stage" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("cd")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 12345:2020/FDIS Suppl 1" do
      subject { "ISO 12345:2020/FDIS Suppl 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:pubid) { "ISO 12345:2020/FDSuppl 1" }
      let(:urn) { "urn:iso:std:iso:12345:stage-50.00:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("12345")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2020")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date).to be_nil
      end

      it "parses stage" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("fdsuppl")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(pubid)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO 12345:2020/PRF Suppl 1" do
      subject { "ISO 12345:2020/PRF Suppl 1" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso:12345:stage-60.00:sup:1:v1" }

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.publisher).to eq("ISO")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.value).to eq("12345")
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2020")
      end

      it "parses supplement number" do
        expect(parsed.number.value).to eq("1")
      end

      it "parses supplement date" do
        expect(parsed.date).to be_nil
      end

      it "parses stage" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.stage_code).to eq("prf")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        pending 'typed_stage removed in V2 architecture'
        expect(parsed.typed_stage.type_code).to eq("suppl")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end
end
