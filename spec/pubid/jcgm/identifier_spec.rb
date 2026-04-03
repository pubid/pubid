# frozen_string_literal: true

require "spec_helper"
require "pubid/jcgm"

RSpec.describe Pubid::Jcgm do
  describe ".parse" do
    context "standard guides" do
      describe "JCGM 100:2008" do
        subject { "JCGM 100:2008" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as Guide" do
          expect(parsed).to be_a(Pubid::Jcgm::Identifiers::Guide)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("JCGM")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("100")
        end

        it "parses date" do
          expect(parsed.date.year).to eq("2008")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JCGM 100:2008(E)" do
        subject { "JCGM 100:2008(E)" }
        let(:parsed) { described_class.parse(subject) }

        it "parses language" do
          expect(parsed.languages.size).to eq(1)
          expect(parsed.languages.first.code).to eq("en")
          expect(parsed.languages.first.original_code).to eq("E")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JCGM 200:2012(E/F)" do
        subject { "JCGM 200:2012(E/F)" }
        let(:parsed) { described_class.parse(subject) }

        it "parses multiple languages" do
          expect(parsed.languages.size).to eq(2)
          expect(parsed.languages.map(&:code)).to eq(["en", "fr"])
          expect(parsed.languages.map(&:original_code)).to eq(["E", "F"])
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "standard guides with language codes" do
      describe "JCGM 200:2007(F)" do
        subject { "JCGM 200:2007(F)" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as Guide" do
          expect(parsed).to be_a(Pubid::Jcgm::Identifiers::Guide)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("JCGM")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("200")
        end

        it "parses date" do
          expect(parsed.date.year).to eq("2007")
        end

        it "parses language" do
          expect(parsed.languages.size).to eq(1)
          expect(parsed.languages.first.code).to eq("fr")
          expect(parsed.languages.first.original_code).to eq("F")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JCGM 200:2008(F)" do
        subject { "JCGM 200:2008(F)" }
        let(:parsed) { described_class.parse(subject) }

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "GUM guides" do
      describe "JCGM GUM-6:2020" do
        subject { "JCGM GUM-6:2020" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as GumGuide" do
          expect(parsed).to be_a(Pubid::Jcgm::Identifiers::GumGuide)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("JCGM")
        end

        it "parses GUM number" do
          expect(parsed.gum_number.value).to eq("6")
        end

        it "parses date" do
          expect(parsed.date.year).to eq("2020")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JCGM GUM-1:2022-11-28" do
        subject { "JCGM GUM-1:2022-11-28" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as GumGuide" do
          expect(parsed).to be_a(Pubid::Jcgm::Identifiers::GumGuide)
        end

        it "parses GUM number" do
          expect(parsed.gum_number.value).to eq("1")
        end

        it "parses full date" do
          expect(parsed.date.year).to eq("2022")
          expect(parsed.date.month).to eq("11")
          expect(parsed.date.day).to eq("28")
        end

        it "renders full date correctly" do
          expect(parsed.date.to_s).to eq("2022-11-28")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "amendments" do
      describe "JCGM 100:2008/Amd 1" do
        subject { "JCGM 100:2008/Amd 1" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as Amendment" do
          expect(parsed).to be_a(Pubid::Jcgm::Identifiers::Amendment)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier).to be_a(Pubid::Jcgm::Identifiers::Guide)
          expect(parsed.base_identifier.number.value).to eq("100")
          expect(parsed.base_identifier.date.year).to eq("2008")
        end

        it "parses iteration" do
          expect(parsed.iteration.value).to eq("1")
        end

        it "has no amendment date" do
          expect(parsed.date).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JCGM 100:2008/Amd 1:2025-07-25" do
        subject { "JCGM 100:2008/Amd 1:2025-07-25" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as Amendment" do
          expect(parsed).to be_a(Pubid::Jcgm::Identifiers::Amendment)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier).to be_a(Pubid::Jcgm::Identifiers::Guide)
        end

        it "parses iteration" do
          expect(parsed.iteration.value).to eq("1")
        end

        it "parses amendment full date" do
          expect(parsed.date.year).to eq("2025")
          expect(parsed.date.month).to eq("07")
          expect(parsed.date.day).to eq("25")
          expect(parsed.date.to_s).to eq("2025-07-25")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
