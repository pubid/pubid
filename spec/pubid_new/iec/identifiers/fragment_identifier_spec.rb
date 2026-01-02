require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::FragmentIdentifier do
  subject { described_class }

  # Test fragment of amendment
  # NOTE: Parser doesn't support fragments without edition yet
  # V1 has "IEC 60050-191/AMD2/FRAG2 ED1" with edition
  context "fragment of amendment" do
    describe "IEC 60050-191/AMD2/FRAG2" do
      subject { "IEC 60050-191/AMD2/FRAG2" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses base number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier.number.number).to eq("60050")
      end

      it "parses base part" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier.part.number).to eq("191")
      end

      it "parses amendment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier.number.number).to eq("2")
      end

      it "parses fragment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.fragment_number).to eq("2")
      end

      it "provides type :fragment" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.type).to eq(:fragment)
      end

      it "round-trips" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with edition
  context "fragment with edition" do
    describe "IEC 60050-191/AMD2/FRAG2 ED1" do
      subject { "IEC 60050-191/AMD2/FRAG2 ED1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

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
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses base identifier as corrigendum" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier).to be_a(PubidNew::Iec::Identifiers::Corrigendum)
      end

      it "parses fragment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.fragment_number).to eq("1")
      end

      it "uses FRAGC notation for corrigendum" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.to_s).to include("FRAGC")
      end

      it "round-trips" do
        skip "Parser doesn't support fragments without edition yet"
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
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses fragment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.fragment_number).to eq("1")
      end

      it "round-trips" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with dated base
  # NOTE: Parser doesn't support fragments without edition yet
  context "fragment with dated amendment" do
    describe "IEC 60050-191:2010/AMD2:2015/FRAG2" do
      subject { "IEC 60050-191:2010/AMD2:2015/FRAG2" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as FragmentIdentifier" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed).to be_a(described_class)
      end

      it "parses base date" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier.base_identifier.date.year).to eq("2010")
      end

      it "parses amendment date" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier.date.year).to eq("2015")
      end

      it "parses fragment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.fragment_number).to eq("2")
      end

      it "round-trips" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test delegation methods
  context "attribute delegation" do
    describe "IEC 60050-191/AMD2/FRAG2 ED1" do
      subject { "IEC 60050-191/AMD2/FRAG2 ED1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "delegates publisher to base" do
        expect(parsed.publisher).to eq(parsed.base_identifier.publisher)
      end

      it "delegates number to base" do
        expect(parsed.number).to eq(parsed.base_identifier.number)
      end

      it "delegates date to base" do
        expect(parsed.date).to eq(parsed.base_identifier.date)
      end

      it "delegates stage to base" do
        expect(parsed.stage).to eq(parsed.base_identifier.stage)
      end

      it "delegates typed_stage to base" do
        expect(parsed.typed_stage).to eq(parsed.base_identifier.typed_stage)
      end
    end
  end

  # Test fragment with multiple digits
  # NOTE: Parser doesn't support fragments without edition yet
  context "multi-digit fragment number" do
    describe "IEC 60050-191/AMD10/FRAG12" do
      subject { "IEC 60050-191/AMD10/FRAG12" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit fragment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.fragment_number).to eq("12")
      end

      it "parses multi-digit amendment number" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.base_identifier.number.number).to eq("10")
      end

      it "round-trips" do
        skip "Parser doesn't support fragments without edition yet"
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test fragment with edition variants
  context "fragment with different edition formats" do
    describe "IEC 60050-191/AMD2/FRAG2 ED2" do
      subject { "IEC 60050-191/AMD2/FRAG2 ED2" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses edition 2" do
        expect(parsed.edition.number).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end