require "spec_helper"

# RB (Research Brief) is a simple NIST series with no dedicated identifier
# class; it routes to the Identifier (base) fallback (like AMS/VTS/TTB/EAB).
RSpec.describe "NIST RB series" do
  describe ".parse" do
    context "basic RB identifier" do
      describe "NIST RB 6" do
        subject { "NIST RB 6" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as a NIST identifier" do
          expect(parsed).to be_a(Pubid::Nist::Identifier)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("RB")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("6")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "RB with revision" do
      describe "NIST RB 4r1" do
        subject { "NIST RB 4r1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses series" do
          expect(parsed.series.to_s).to eq("RB")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("4")
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "dotted (DOI / machine-readable) form" do
      describe "NIST.RB.4r1" do
        subject { "NIST.RB.4r1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses series" do
          expect(parsed.series.to_s).to eq("RB")
        end

        it "renders the mr form" do
          expect(parsed.to_s(:mr)).to eq("NIST.RB.4r1")
        end
      end
    end
  end
end
