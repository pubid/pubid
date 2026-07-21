require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::LetterCircular do
  subject { described_class }

  describe ".parse" do
    context "basic LC identifiers" do
      describe "NBS LC 1" do
        subject { "NBS LC 1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("LCIRC") # Internal representation
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject.sub(" LC ", " LC "))
        end
      end

      describe "NBS LC 1" do
        subject { "NBS LC 1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes LC to LC" do
          expect(parsed.to_s).to eq("NBS LC 1")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end
      end

      describe "NBS LC 1088" do
        subject { "NBS LC 1088" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to LC format" do
          expect(parsed.to_s).to eq("NBS LC 1088")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1088")
        end
      end
    end

    context "LC with revision year" do
      describe "NBS LC 1013r1953" do
        subject { "NBS LC 1013r1953" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to LC with revision" do
          expect(parsed.to_s).to eq("NBS LC 1013r1953")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1013")
        end

        it "parses revision year" do
          expect(parsed.edition.to_s).to eq("r1953")
        end
      end

      describe "NBS LC 1013rv1953" do
        subject { "NBS LC 1013rv1953" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to LC format" do
          expect(parsed.to_s).to eq("NBS LC 1013rv1953")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1013")
        end
      end

      describe "NBS LC 145" do
        subject { "NBS LC 145" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject.sub(" LC ", " LC "))
        end
      end

      describe "NBS LC 378" do
        subject { "NBS LC 378" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject.sub(" LC ", " LC "))
        end
      end
    end

    context "LC with letter suffix" do
      describe "NBS LC 378g" do
        subject { "NBS LC 378g" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes LC to LC and letter suffix to uppercase" do
          expect(parsed.to_s).to eq("NBS LC 378G")
        end

        it "parses number with letter suffix" do
          expect(parsed.number.value).to eq("378G")
        end
      end

      describe "NBS LC 378G" do
        subject { "NBS LC 378G" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips with uppercase suffix" do
          expect(parsed.to_s).to eq(subject.sub(" LC ", " LC "))
        end

        it "parses number with letter" do
          expect(parsed.number.value).to eq("378G")
        end
      end
    end

    context "LC with language codes" do
      describe "NBS LC 1088sp" do
        subject { "NBS LC 1088sp" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes sp to spa language code" do
          expect(parsed.to_s).to eq("NBS LC 1088 spa")
        end

        it "parses language code" do
          expect(parsed.language).not_to be_nil
        end
      end

      describe "NBS LC 378(sp)" do
        subject { "NBS LC 378(sp)" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses parenthetical language code" do
          expect(parsed.language).not_to be_nil
        end

        it "renders language in space format" do
          expect(parsed.to_s).to eq("NBS LC 378 spa")
        end
      end
    end

    context "LC with supplement date" do
      describe "NBS.LC.118sup12/1926" do
        subject { "NBS.LC.118sup12/1926" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as CircularSupplement with LetterCircular base" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
          expect(parsed.base).to be_a(described_class)
        end

        it "normalizes supplement with date to Upd format" do
          expect(parsed.to_s).to eq("NBS LC 118sup/Upd1-192612")
        end

        it "parses number" do
          expect(parsed.base.number.value).to eq("118")
        end

        it "parses supplement" do
          expect(parsed.base).not_to be_nil
        end
      end

      describe "NBS LC 118sup" do
        subject { "NBS LC 118sup" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        # Collapsed onto a plain LetterCircular with an empty (present)
        # supplement part, instead of a CircularSupplement wrapper.
        it "parses as a plain LetterCircular" do
          expect(parsed).to be_a(described_class)
          expect(parsed).not_to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "carries the supplement as an isolated (empty) part" do
          expect(parsed.number.value).to eq("118")
          expect(parsed.supplement).not_to be_nil
          expect(parsed.supplement.value_string).to eq("")
        end

        it "normalizes to LC with supp" do
          # Note: "sup" is normalized to "supp" for single definition of truth
          expect(parsed.to_s).to eq("NBS LC 118sup")
        end
      end

      describe "NBS LC 378sup1/1927" do
        subject { "NBS LC 378sup1/1927" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as CircularSupplement with LetterCircular base" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
          expect(parsed.base).to be_a(described_class)
        end

        it "normalizes supplement to Upd format" do
          expect(parsed.to_s).to eq("NBS LC 378sup/Upd1-192701")
        end
      end
    end

    context "LC with revision date" do
      describe "NBS.LC.145r11/1925" do
        subject { "NBS.LC.145r11/1925" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as CircularSupplement with LetterCircular base" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
          expect(parsed.base).to be_a(described_class)
        end

        it "normalizes revision with date to Upd format" do
          expect(parsed.to_s).to eq("NBS LC 145/Upd1-192511")
        end

        it "parses number" do
          expect(parsed.base.number.value).to eq("145")
        end
      end

      # Single-digit revision: year+revision fuse into an unpadded 5-digit Upd
      # suffix (1925 + 6 -> "19256", not "192506"). Regression guard for the
      # round-trip fix — this generated output previously raised
      # Parslet::ParseFailed when fed back in.
      describe "NBS.LC.145r6/1925" do
        subject { "NBS.LC.145r6/1925" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as CircularSupplement with LetterCircular base" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
          expect(parsed.base).to be_a(described_class)
        end

        it "normalizes revision with date to an unpadded Upd format" do
          expect(parsed.to_s).to eq("NBS LC 145/Upd1-19256")
        end

        it "parses number" do
          expect(parsed.base.number.value).to eq("145")
        end

        it "round-trips its generated short form" do
          out = parsed.to_s
          expect(Pubid::Nist.parse(out).to_s).to eq(out)
        end

        it "round-trips its generated MR form" do
          out = parsed.to_s(:mr)
          expect(out).to eq("NBS.LC.145-upd1-19256")
          expect(Pubid::Nist.parse(out).to_s(:mr)).to eq(out)
        end
      end

      describe "NBS LC 145r1926" do
        subject { "NBS LC 145r1926" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses revision year" do
          # "r1926" is parsed as edition (type="r", id="1926")
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1926")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "LC MR format" do
      describe "NBS.LC.887" do
        subject { "NBS.LC.887" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as LetterCircular" do
          expect(parsed).to be_a(described_class)
        end

        it "renders in MR format" do
          expect(parsed.to_s(format: :mr)).to eq("NBS.LC.887")
        end

        it "normalizes LC to LC as single definition of truth" do
          expect(parsed.series.to_s).to eq("LCIRC") # Internal representation
        end

        it "parses number" do
          expect(parsed.number.value).to eq("887")
        end
      end
    end
  end
end
