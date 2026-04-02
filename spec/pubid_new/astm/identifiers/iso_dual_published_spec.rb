# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Astm::Identifiers::IsoDualPublished do
  subject { described_class }

  describe "ISO/ASTM dual-published standards (5xxxx series)" do

    describe "parses normal identifier" do
      subject { "ASTM 52303-24e1" }
      let(:parsed) { Pubid::Astm.parse(subject) }

      it "parses ASTM 52303-24e1" do
        expect(parsed).to be_a(described_class)
        expect(parsed.publisher).to eq("ASTM")
        expect(parsed.code.number).to eq("52303")
        expect(parsed.year).to eq("2024")
        expect(parsed.edition).to eq("1")
        expect(parsed.code.letter).to be_nil
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "parses reapproval identifier" do
      subject { "ASTM 52921-13(2018)e1" }
      let(:parsed) { Pubid::Astm.parse(subject) }

      it "parses ASTM 52921-13(2018)e1" do
        expect(parsed).to be_a(described_class)
        expect(parsed.code.number).to eq("52921")
        expect(parsed.year).to eq("2013")
        expect(parsed.reapproval).to eq("2018")
        expect(parsed.edition).to eq("1")
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "parses identifier with edition" do
      subject { "ASTM 51956-19e1" }
      let(:parsed) { Pubid::Astm.parse(subject) }

      it "parses ASTM 51956-19e1" do
        expect(parsed).to be_a(described_class)
        expect(parsed.code.number).to eq("51956")
        expect(parsed.year).to eq("2019")
        expect(parsed.edition).to eq("1")
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "parses identifier without edition" do
      subject { "ASTM 52900-15" }
      let(:parsed) { Pubid::Astm.parse(subject) }

      it "parses ASTM 52900-15" do
        expect(parsed).to be_a(described_class)
        expect(parsed.code.number).to eq("52900")
        expect(parsed.year).to eq("2015")
        expect(parsed.edition).to be_nil
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "semantic classification" do
      it "5xxxx digit-only standards are IsoDualPublished not generic Standard" do
        id = Pubid::Astm.parse("ASTM 52303-24e1")
        expect(id).to be_a(described_class)
        # It IS also a Standard (due to inheritance), which is correct
        expect(id).to be_a(Pubid::Astm::Identifiers::Standard)
      end

      it "inherits from Standard class" do
        expect(described_class.ancestors).to include(Pubid::Astm::Identifiers::Standard)
      end
    end

    describe "ISO counterpart relationship" do
      let(:astm_version) { Pubid::Astm.parse("ASTM 52303-24e1") }

      it "ASTM 52303-24e1 corresponds to ISO/ASTM 52303:2024" do

        expect(astm_version.code.number).to eq("52303")
        expect(astm_version.year).to eq("2024")
        expect(astm_version.edition).to eq("1")
        expect(astm_version.to_s).to eq("ASTM 52303-24e1")

        # ISO publishes as: ISO/ASTM 52303:2024
        iso_version = astm_version.to_iso_identifier
        expect(iso_version).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(iso_version.number.number).to eq("52303")
        expect(iso_version.date.year).to eq("2024")
        expect(iso_version.publisher.copublisher.first).to eq("ASTM")
        expect(iso_version.to_s).to eq("ISO/ASTM 52303:2024")
      end
    end
  end
end
