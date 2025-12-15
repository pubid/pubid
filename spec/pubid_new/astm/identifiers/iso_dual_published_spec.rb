# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::IsoDualPublished do
  subject { described_class }

  describe "ISO/ASTM dual-published standards (5xxxx series)" do
    context "ASTM 52303-24e1" do
      subject { "ASTM 52303-24e1" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher).to eq("ASTM")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("52303")
      end

      it "parses year" do
        expect(parsed.year).to eq("2024")
      end

      it "parses edition" do
        expect(parsed.editorial).to eq("1")
      end

      it "has no letter prefix" do
        expect(parsed.code.letter).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ASTM 52921-13(2018)e1" do
      subject { "ASTM 52921-13(2018)e1" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.code.number).to eq("52921")
      end

      it "parses year" do
        expect(parsed.year).to eq("2013")
      end

      it "parses reapproval" do
        expect(parsed.reapproval).to eq("2018")
      end

      it "parses edition" do
        expect(parsed.editorial).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ASTM 51956-19e1" do
      subject { "ASTM 51956-19e1" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.code.number).to eq("51956")
      end

      it "parses year" do
        expect(parsed.year).to eq("2019")
      end

      it "parses edition" do
        expect(parsed.editorial).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ASTM 51607-22" do
      subject { "ASTM 51607-22" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.code.number).to eq("51607")
      end

      it "parses year" do
        expect(parsed.year).to eq("2022")
      end

      it "has no edition" do
        expect(parsed.editorial).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ASTM 52900-15" do
      subject { "ASTM 52900-15" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.code.number).to eq("52900")
      end

      it "parses year" do
        expect(parsed.year).to eq("2015")
      end

      it "has no edition" do
        expect(parsed.editorial).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ASTM 52628-15" do
      subject { "ASTM 52628-15" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.code.number).to eq("52628")
      end

      it "parses year" do
        expect(parsed.year).to eq("2015")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "semantic classification" do
      it "5xxxx digit-only standards are IsoDualPublished not generic Standard" do
        id = PubidNew::Astm.parse("ASTM 52303-24e1")
        expect(id).to be_a(described_class)
        expect(id.class).to eq(described_class)
        # It IS also a Standard (due to inheritance), which is correct
        expect(id).to be_a(PubidNew::Astm::Identifiers::Standard)
      end

      it "inherits from Standard class" do
        expect(described_class.ancestors).to include(PubidNew::Astm::Identifiers::Standard)
      end

      it "uses same rendering as Standard" do
        iso_dual = PubidNew::Astm.parse("ASTM 52303-24e1")
        expect(iso_dual.to_s).to eq("ASTM 52303-24e1")
      end
    end

    describe "ISO counterpart relationship" do
      it "ASTM 52303-24e1 corresponds to ISO/ASTM 52303:2024" do
        astm_version = PubidNew::Astm.parse("ASTM 52303-24e1")
        expect(astm_version.code.number).to eq("52303")
        expect(astm_version.year).to eq("2024")
        # ISO publishes as: ISO/ASTM 52303:2024
        # ASTM publishes as: ASTM 52303-24e1 (edition 1)
      end
    end
  end
end