require "spec_helper"

RSpec.describe PubidNew::Iso::Identifiers::InternationalStandardizedProfile do
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

    context "parses identifiers from iso-isp.txt" do
      let(:examples_file) { "iso/iso-isp.txt" }

      it_behaves_like "parse identifiers from file"
    end
  end

  # Test basic identifiers
  context "basic identifiers" do
    # Test normal dated ISP
    context "dated ISP" do
      describe "ISO/IEC ISP 10611-3:2003" do
        subject { "ISO/IEC ISP 10611-3:2003" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:10611:-3" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("10611")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("3")
        end

        it "parses date" do
          expect(parsed.date.year).to eq("2003")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("ISP")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/IEC ISP 12345:2020" do
        subject { "ISO/IEC ISP 12345:2020" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:12345" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("12345")
        end

        it "parses part" do
          expect(parsed.part&.value).to be_nil
        end

        it "parses date" do
          expect(parsed.date.year).to eq("2020")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("ISP")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end

    # Test normal undated ISP
    context "undated ISP" do
      describe "ISO/IEC ISP 12062-3" do
        subject { "ISO/IEC ISP 12062-3" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:12062:-3" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("12062")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("3")
        end

        it "parses date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("ISP")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/IEC ISP 10000" do
        subject { "ISO/IEC ISP 10000" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:10000" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("10000")
        end

        it "parses part" do
          expect(parsed.part&.value).to be_nil
        end

        it "parses date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("ISP")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end

  # Test publishers and copublishers
  context "publishers" do
    context "ISO only publisher" do
      describe "ISO ISP 12066-1" do
        subject { "ISO ISP 12066-1" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:pubid) { "ISO/ISP 12066-1" }
        let(:urn) { "urn:iso:std:iso:isp:12066:-1" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.copublishers).to be_nil
        end

        it "parses number" do
          expect(parsed.number.value).to eq("12066")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end

        it "parses date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(pubid)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "provides stage code" do
          expect(parsed.typed_stage.stage_code).to eq("published")
        end

        it "provides typed_stage with abbreviation" do
          expect(parsed.typed_stage.abbr.first).to eq("ISP")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end

  # Test stages
  context "stages" do
    context "proposal" do
      describe "ISO/IEC NP ISP 29110-4-2" do
        subject { "ISO/IEC NP ISP 29110-4-2" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:29110:-4-2:stage-10.00" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("29110")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("4")
        end

        it "parses subpart" do
          expect(parsed.subpart.value).to eq("2")
        end

        it "parses stage" do
          expect(parsed.typed_stage.stage_code).to eq("np")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end

    context "preparatory" do
      describe "ISO/IEC WD ISP 10613-2" do
        subject { "ISO/IEC WD ISP 10613-2" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:10613:-2:stage-20.20" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("10613")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("2")
        end

        it "parses stage" do
          expect(parsed.typed_stage.stage_code).to eq("wd")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end

    context "enquiry" do
      describe "ISO/IEC DISP 12069" do
        subject { "ISO/IEC DISP 12069" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso-iec:isp:12069:stage-40.00" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.publisher.copublisher.first).to eq("IEC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("12069")
        end

        it "parses stage" do
          expect(parsed.typed_stage.stage_code).to eq("disp")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end

      describe "ISO/DISP 12066-1" do
        subject { "ISO/DISP 12066-1" }
        let(:parsed) { PubidNew::Iso.parse(subject) }
        let(:urn) { "urn:iso:std:iso:isp:12066:-1:stage-40.00" }

        it "parses publisher" do
          expect(parsed.publisher.publisher).to eq("ISO")
        end

        it "parses copublisher" do
          expect(parsed.copublishers).to be_nil
        end

        it "parses number" do
          expect(parsed.number.value).to eq("12066")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end

        it "parses stage" do
          expect(parsed.typed_stage.stage_code).to eq("disp")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "provides type code" do
          expect(parsed.typed_stage.type_code).to eq("isp")
        end

        it "generates urn" do
          expect(parsed.to_urn).to eq(urn)
        end
      end
    end
  end

  # Test complex parts
  context "complex parts" do
    describe "ISO/IEC ISP 11183-1-1:2001" do
      subject { "ISO/IEC ISP 11183-1-1:2001" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso-iec:isp:11183:-1-1" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("11183")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("1")
      end

      it "parses subpart" do
        expect(parsed.subpart.value).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2001")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("isp")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("ISP")
      end

      it "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
end

# Test languages
  context "languages" do
    describe "ISO/IEC ISP 10611-3:2003(en)" do
      subject { "ISO/IEC ISP 10611-3:2003(en)" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso-iec:isp:10611:-3:en" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("10611")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("3")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2003")
      end

      it "parses languages" do
        expect(parsed.languages.map(&:code)).to eq(%w[en])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("isp")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("ISP")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end

    describe "ISO/IEC ISP 12062-3(E/F)" do
      subject { "ISO/IEC ISP 12062-3(E/F)" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:normalized) { "ISO/IEC ISP 12062-3(en,fr)" }
      let(:urn) { "urn:iso:std:iso-iec:isp:12062:-3:en,fr" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("12062")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("3")
      end

      it "parses date" do
        expect(parsed.date).to be_nil
      end

      it "parses languages" do
        expect(parsed.languages.map(&:code)).to eq(%w[en fr])
      end

      it "normalizes language format" do
        expect(parsed.to_s).to eq(normalized)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("isp")
      end

      it "provides stage code" do
        expect(parsed.typed_stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation" do
        expect(parsed.typed_stage.abbr.first).to eq("ISP")
      end

      it "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
end

# Test stage iterations
  context "stage iterations" do
    describe "ISO/IEC WD ISP 10613-2.2" do
      subject { "ISO/IEC WD ISP 10613-2.2" }
      let(:parsed) { PubidNew::Iso.parse(subject) }
      let(:urn) { "urn:iso:std:iso-iec:isp:10613:-2:stage-20.20.v2" }

      it "parses publisher" do
        expect(parsed.publisher.publisher).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher.first).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("10613")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("2")
      end

      it "parses stage" do
        expect(parsed.typed_stage.stage_code).to eq("wd")
      end

      it "parses iteration" do
        expect(parsed.stage_iteration.value).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.typed_stage.type_code).to eq("isp")
      end

      xit "generates urn" do
        expect(parsed.to_urn).to eq(urn)
      end
    end
  end
end
