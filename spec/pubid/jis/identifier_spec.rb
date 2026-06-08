# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Jis::Identifier do
  describe ".parse" do
    context "basic JIS identifiers" do
      describe "JIS B 0001" do
        subject { "JIS B 0001" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as JapaneseIndustrialStandard" do
          expect(parsed).to be_a(Pubid::Jis::Identifiers::JapaneseIndustrialStandard)
        end

        it "parses series" do
          expect(parsed.code.series).to eq("B")
        end

        it "parses number" do
          expect(parsed.code.number).to eq(1)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "renders without publisher" do
          expect(parsed.to_s(with_publisher: false)).to eq("B 0001")
        end
      end

      describe "JIS C 61000-3-2" do
        subject { "JIS C 61000-3-2" }

        let(:parsed) { described_class.parse(subject) }

        it "parses series" do
          expect(parsed.code.series).to eq("C")
        end

        it "parses number" do
          expect(parsed.code.number).to eq(61000)
        end

        it "parses parts" do
          expect(parsed.code.parts).to eq([3, 2])
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JIS C 61000-3-2:2011" do
        subject { "JIS C 61000-3-2:2011" }

        let(:parsed) { described_class.parse(subject) }

        it "parses year" do
          expect(parsed.year).to eq(2011)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "identifiers with language codes" do
      describe "JIS Z 8301:2019(J)" do
        subject { "JIS Z 8301:2019(J)" }

        let(:parsed) { described_class.parse(subject) }

        it "parses language as Japanese" do
          expect(parsed.language).to eq("J")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JIS Z 8301:2019(E)" do
        subject { "JIS Z 8301:2019(E)" }

        let(:parsed) { described_class.parse(subject) }

        it "parses language as English" do
          expect(parsed.language).to eq("E")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "all-parts notation (規格群)" do
      describe "JIS C 0617（規格群）" do
        subject { "JIS C 0617（規格群）" }

        let(:parsed) { described_class.parse(subject) }

        it "parses all_parts as true" do
          expect(parsed.all_parts?).to be true
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        context "when compared with identifier with part" do
          let(:other) { described_class.parse("JIS C 0617-2") }

          it "returns true (all_parts matches any part)" do
            expect(parsed == other).to be true
          end
        end

        context "when compared with identifier with part and year" do
          let(:other) { described_class.parse("JIS C 0617-2:2017") }

          it "returns true (all_parts matches any variation)" do
            expect(parsed == other).to be true
          end
        end

        context "when compared with different identifier" do
          let(:other) { described_class.parse("JIS C 0618-1") }

          it "returns false (different number)" do
            expect(parsed == other).to be false
          end
        end
      end

      describe "JIS B 0060（規格群）" do
        subject { "JIS B 0060（規格群）" }

        let(:parsed) { described_class.parse(subject) }

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "identifiers without whitespace (normalization)" do
      describe "JISX0902-1:2019" do
        subject { "JISX0902-1:2019" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes to standard format" do
          expect(parsed.to_s).to eq("JIS X 0902-1:2019")
        end
      end

      describe "JISX0836:2005" do
        subject { "JISX0836:2005" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes to standard format" do
          expect(parsed.to_s).to eq("JIS X 0836:2005")
        end
      end
    end

    context "technical report identifiers" do
      describe "JIS TR Z 8301:2019" do
        subject { "JIS TR Z 8301:2019" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as TechnicalReport" do
          expect(parsed).to be_a(Pubid::Jis::Identifiers::TechnicalReport)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JIS/TR X 0005:1998" do
        subject { "JIS/TR X 0005:1998" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes slash separator to space" do
          expect(parsed.to_s).to eq("JIS TR X 0005:1998")
        end
      end

      describe "TR B 0035:2019" do
        subject { "TR B 0035:2019" }

        let(:parsed) { described_class.parse(subject) }

        it "adds missing JIS prefix" do
          expect(parsed.to_s).to eq("JIS TR B 0035:2019")
        end
      end
    end

    context "technical specification identifiers" do
      describe "JIS TS Z 8301:2019" do
        subject { "JIS TS Z 8301:2019" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as TechnicalSpecification" do
          expect(parsed).to be_a(Pubid::Jis::Identifiers::TechnicalSpecification)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "TS Z0030-1:2017" do
        subject { "TS Z0030-1:2017" }

        let(:parsed) { described_class.parse(subject) }

        it "adds missing JIS prefix and normalizes spacing" do
          expect(parsed.to_s).to eq("JIS TS Z 0030-1:2017")
        end
      end
    end

    context "amendment identifiers" do
      describe "JIS A 0001:1999/AMD 1:2000" do
        subject { "JIS A 0001:1999/AMD 1:2000" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as Amendment" do
          expect(parsed).to be_a(Pubid::Jis::Identifiers::Amendment)
        end

        it "parses base identifier" do
          expect(parsed.base.code.series).to eq("A")
          expect(parsed.base.code.number).to eq(1)
          expect(parsed.base.year).to eq(1999)
        end

        it "parses amendment number" do
          expect(parsed.number).to eq(1)
        end

        it "parses amendment year" do
          expect(parsed.year).to eq(2000)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "renders without publisher" do
          expect(parsed.to_s(with_publisher: false)).to eq("A 0001:1999/AMD 1:2000")
        end
      end

      describe "JIS X 0208:1997/AMENDMENT 1:2012" do
        subject { "JIS X 0208:1997/AMENDMENT 1:2012" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes AMENDMENT to AMD" do
          expect(parsed.to_s).to eq("JIS X 0208:1997/AMD 1:2012")
        end
      end
    end

    context "explanation identifiers" do
      describe "JIS K 2151:2004/EXPL" do
        subject { "JIS K 2151:2004/EXPL" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as Explanation" do
          expect(parsed).to be_a(Pubid::Jis::Identifiers::Explanation)
        end

        it "parses base identifier" do
          expect(parsed.base.code.series).to eq("K")
          expect(parsed.base.code.number).to eq(2151)
          expect(parsed.base.year).to eq(2004)
        end

        it "has no explanation number" do
          expect(parsed.number).to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "JIS K 2249-4:2011/EXPLANATION 4" do
        subject { "JIS K 2249-4:2011/EXPLANATION 4" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes EXPLANATION to EXPL" do
          expect(parsed.to_s).to eq("JIS K 2249-4:2011/EXPL 4")
        end

        it "parses explanation number" do
          expect(parsed.number).to eq(4)
        end
      end
    end

    context "Japanese character normalization" do
      describe "full-width dash" do
        subject { "JIS C 61000ｰ3ｰ2" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes to regular dash" do
          expect(parsed.to_s).to eq("JIS C 61000-3-2")
        end
      end

      describe "full-width space" do
        subject { "JIS　B　0001" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes to regular space" do
          expect(parsed.to_s).to eq("JIS B 0001")
        end
      end

      describe "full-width colon" do
        subject { "JIS C 61000-3-2：2011" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes to regular colon" do
          expect(parsed.to_s).to eq("JIS C 61000-3-2:2011")
        end
      end
    end

    context "corrigenda" do
      describe "JIS B 3700-11:1996/CORRIGENDUM 1:2002" do
        subject { "JIS B 3700-11:1996/CORRIGENDUM 1:2002" }

        let(:parsed) { described_class.parse(subject) }

        it "parses as Corrigendum" do
          expect(parsed).to be_a(Pubid::Jis::Identifiers::Corrigendum)
        end

        it "inherits the code from the base document" do
          expect(parsed.code.series).to eq("B")
          expect(parsed.code.number).to eq(3700)
          expect(parsed.base.year).to eq(1996)
        end

        it "parses the corrigendum number and year" do
          expect(parsed.number).to eq(1)
          expect(parsed.year).to eq(2002)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CORR abbreviation" do
        subject { "JIS A 0001:1999/CORR 1:2002" }

        let(:parsed) { described_class.parse(subject) }

        it "normalizes to CORRIGENDUM" do
          expect(parsed.to_s).to eq("JIS A 0001:1999/CORRIGENDUM 1:2002")
        end
      end
    end
  end
end
