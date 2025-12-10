# frozen_string_literal: true

require "spec_helper"
require "pubid_new/jcgm"

RSpec.describe PubidNew::Jcgm do
  describe ".parse" do
    context "standard guides with language codes" do
      describe "JCGM 200:2007(F)" do
        subject { "JCGM 200:2007(F)" }
        let(:parsed) { described_class.parse(subject) }

        it "parses as Guide" do
          expect(parsed).to be_a(PubidNew::Jcgm::Identifiers::Guide)
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
  end
end