require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::FragmentIdentifier do
  subject { described_class }

  # Test fragment of amendment
  context "fragment of amendment" do
    describe "IEC 60050-191/AMD2/FRAG2" do
      subject { "IEC 60050-191/AMD2/FRAG2" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses base number" do
        expect(parsed.base_identifier.base_identifier.number.value).to eq("60050")
      end

      it "parses base part" do
        expect(parsed.base_identifier.base_identifier.part.value).to eq("191")
      end

      it "parses amendment number" do
        expect(parsed.base_identifier.number.value).to eq("2")
      end

      it "parses fragment number" do
        expect(parsed.fragment_number).to eq("2")
      end

      it "is a FragmentIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with edition
  context "fragment with edition" do
    describe "IEC 60050-191/AMD2/FRAG2 ED1" do
      subject { "IEC 60050-191/AMD2/FRAG2 ED1" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses fragment number" do
        expect(parsed.fragment_number).to eq("2")
      end

      it "parses edition" do
        expect(parsed.edition.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment of corrigendum (FRAGC notation)
  # NOTE: Parser doesn't support fragments without edition yet
  # V1 patterns include edition
  context "fragment of corrigendum" do
    describe "IEC 60050-191/COR1/FRAGC1" do
      subject { "IEC 60050-191/COR1/FRAGC1" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses base identifier as corrigendum" do
        expect(parsed.base_identifier).to be_a(Pubid::Iec::Identifiers::Corrigendum)
      end

      it "parses fragment number" do
        expect(parsed.fragment_number).to eq("1")
      end

      it "uses FRAGC notation for corrigendum" do
        expect(parsed.to_s).to include("FRAGC")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with copublisher
  # NOTE: Parser doesn't support fragments without edition yet
  # V1 patterns include edition
  context "fragment with copublisher" do
    describe "ISO/IEC 60050-191/AMD1/FRAG1" do
      subject { "ISO/IEC 60050-191/AMD1/FRAG1" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses fragment number" do
        expect(parsed.fragment_number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with dated base
  # NOTE: Parser doesn't support fragments without edition yet
  context "fragment with dated amendment" do
    describe "IEC 60050-191:2010/AMD2:2015/FRAG2" do
      subject { "IEC 60050-191:2010/AMD2:2015/FRAG2" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base date" do
        expect(parsed.base_identifier.base_identifier.date.year).to eq("2010")
      end

      it "parses amendment date" do
        expect(parsed.base_identifier.date.year).to eq("2015")
      end

      it "parses fragment number" do
        expect(parsed.fragment_number).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test delegation methods
  context "attribute delegation" do
    describe "IEC 60050-191/AMD2/FRAG2 ED1" do
      subject { "IEC 60050-191/AMD2/FRAG2 ED1" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "delegates publisher to base" do
        expect(parsed.publisher).to eq(parsed.base_identifier.publisher)
      end

      it "delegates number to base" do
        expect(parsed.number).to eq(parsed.base_identifier.number)
      end

      it "delegates date to base" do
        expect(parsed.date).to eq(parsed.base_identifier.date)
      end

      it "has its own stage from FRAG typed stage" do
        expect(parsed.stage).not_to be_nil
        expect(parsed.stage.abbr).to eq("FRAG")
      end

      it "has its own FRAG typed stage" do
        expect(parsed.typed_stage).not_to be_nil
        expect(parsed.typed_stage.type_code).to eq("frag")
        expect(parsed.typed_stage.abbr).to include("FRAG")
      end
    end
  end

  # Test fragment with multiple digits
  # NOTE: Parser doesn't support fragments without edition yet
  context "multi-digit fragment number" do
    describe "IEC 60050-191/AMD10/FRAG12" do
      subject { "IEC 60050-191/AMD10/FRAG12" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses multi-digit fragment number" do
        expect(parsed.fragment_number).to eq("12")
      end

      it "parses multi-digit amendment number" do
        expect(parsed.base_identifier.number.value).to eq("10")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with edition variants
  context "fragment with different edition formats" do
    describe "IEC 60050-191/AMD2/FRAG2 ED2" do
      subject { "IEC 60050-191/AMD2/FRAG2 ED2" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses edition 2" do
        expect(parsed.edition.number).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test FRAG typed stages registration
  context "FRAG typed stages" do
    let(:frag_stages) { described_class::TYPED_STAGES }

    it "defines 8 typed stages" do
      expect(frag_stages.length).to eq(8)
    end

    it "all typed stages have type_code :frag" do
      expect(frag_stages.map(&:type_code).uniq).to eq(["frag"])
    end

    it "includes PWI Frag stage" do
      stage = frag_stages.find { |s| s.abbr.include?("PWI Frag") }
      expect(stage).not_to be_nil
      expect(stage.name).to eq("Preliminary Work Item Fragment")
      expect(stage.stage_code).to eq("pwi")
      expect(stage.harmonized_stages).to include("00.00", "00.99")
    end

    it "includes NP Frag stage" do
      stage = frag_stages.find { |s| s.abbr.include?("NP Frag") }
      expect(stage).not_to be_nil
      expect(stage.stage_code).to eq("np")
      expect(stage.harmonized_stages).to include("10.00", "10.98")
    end

    it "includes CDFRAG stage" do
      stage = frag_stages.find { |s| s.abbr.include?("CDFRAG") }
      expect(stage).not_to be_nil
      expect(stage.name).to eq("Committee Draft Fragment")
      expect(stage.stage_code).to eq("cd")
      expect(stage.harmonized_stages).to include("30.00", "30.99")
    end

    it "includes DFRAG stage" do
      stage = frag_stages.find { |s| s.abbr.include?("DFRAG") }
      expect(stage).not_to be_nil
      expect(stage.name).to eq("Draft Fragment")
      expect(stage.stage_code).to eq("dfrag")
      expect(stage.harmonized_stages).to include("40.00", "40.99")
    end

    it "includes FDFRAG stage with PRF Frag alias" do
      stage = frag_stages.find { |s| s.abbr.include?("FDFRAG") }
      expect(stage).not_to be_nil
      expect(stage.abbr).to include("FDFRAG", "PRF Frag")
      expect(stage.harmonized_stages).to include("50.00", "50.99")
    end

    it "includes FRAG (published) stage" do
      stage = frag_stages.find do |s|
        s.abbr.include?("FRAG") && s.stage_code == "published"
      end
      expect(stage).not_to be_nil
      expect(stage.name).to eq("Fragment")
      expect(stage.harmonized_stages).to include("60.00", "90.99", "95.99")
    end
  end

  # Test self-describing module integration
  context "Module integration" do
    it "FragmentIdentifier is discoverable as an IEC identifier type" do
      expect(Pubid::Iec.identifier_types).to include(described_class)
    end

    it "FRAG abbreviation is lookupable via Pubid::Iec" do
      ts = Pubid::Iec.locate_stage("FRAG")
      expect(ts.type_code).to eq("frag")
      expect(ts.abbr).to include("FRAG")
    end

    it "CDFRAG abbreviation is lookupable via Pubid::Iec" do
      ts = Pubid::Iec.locate_stage("CDFRAG")
      expect(ts.type_code).to eq("frag")
      expect(ts.name).to eq("Committee Draft Fragment")
    end

    it "DFRAG abbreviation is lookupable via Pubid::Iec" do
      ts = Pubid::Iec.locate_stage("DFRAG")
      expect(ts.type_code).to eq("frag")
      expect(ts.name).to eq("Draft Fragment")
    end

    it "FDFRAG abbreviation is lookupable via Pubid::Iec" do
      ts = Pubid::Iec.locate_stage("FDFRAG")
      expect(ts.type_code).to eq("frag")
      expect(ts.name).to eq("Final Draft Fragment")
    end

    it "FragmentIdentifier is lookupable by type_code :frag" do
      klass = Pubid::Iec.locate_type(:frag)
      expect(klass).to eq(described_class)
    end
  end
end
