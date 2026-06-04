module Pubid::Iso
  RSpec.describe "annotated rendering" do
    describe "simple ISO identifier" do
      subject { Identifier.parse("ISO 1234").to_s(annotated: true) }

      it "annotates publisher and number" do
        expect(subject).to eq('<span class="publisher">ISO</span> <span class="docnumber">1234</span>')
      end
    end

    describe "ISO identifier with year and part" do
      subject { Identifier.parse("ISO 1234-1:2013").to_s(annotated: true) }

      it "annotates all components" do
        expect(subject).to eq(
          '<span class="publisher">ISO</span> <span class="docnumber">1234</span>' \
          '-<span class="part">1</span>:<span class="year">2013</span>'
        )
      end
    end

    describe "copublisher with type" do
      subject { Identifier.parse("ISO/IEC TR 2131:2013").to_s(annotated: true) }

      it "annotates publisher, type, number, and year" do
        expect(subject).to eq(
          '<span class="publisher">ISO/IEC</span> <span class="doctype">TR</span>' \
          ' <span class="docnumber">2131</span>:<span class="year">2013</span>'
        )
      end
    end

    describe "full example from issue" do
      subject { Identifier.parse("ISO/IEC/IEEE TR 2131-1:2013").to_s(annotated: true) }

      it "annotates all semantic components" do
        expect(subject).to eq(
          '<span class="publisher">ISO/IEC/IEEE</span> <span class="doctype">TR</span>' \
          ' <span class="docnumber">2131</span>-<span class="part">1</span>:<span class="year">2013</span>'
        )
      end
    end

    # Identifiers carrying a stage (DIS, FDIS, CD, ...) exercise the ISO
    # renderer's two-phase stage handling: render_stage returns the Stage
    # object unchanged in the prerender phase, and postrender_stage renders it
    # in render_identifier. Annotation must not collapse the Stage object into
    # a String during prerender, or the second phase raises NoMethodError on
    # Stage#empty_abbr?. See pubid-iso annotated-stage regression.
    describe "ISO identifier with stage" do
      subject { Identifier.parse("ISO/DIS 10303-62").to_s(annotated: true) }

      it "annotates the stage in its own span" do
        expect(subject).to eq(
          '<span class="publisher">ISO</span>/<span class="stage">DIS</span>' \
          ' <span class="docnumber">10303</span>-<span class="part">62</span>'
        )
      end
    end

    describe "ISO identifier with stage, part and year" do
      subject { Identifier.parse("ISO/FDIS 1234-1:2013").to_s(annotated: true) }

      it "annotates stage alongside all other components" do
        expect(subject).to eq(
          '<span class="publisher">ISO</span>/<span class="stage">FDIS</span>' \
          ' <span class="docnumber">1234</span>-<span class="part">1</span>' \
          ':<span class="year">2013</span>'
        )
      end
    end

    describe "ISO identifier with committee-draft stage" do
      subject { Identifier.parse("ISO/CD 1234").to_s(annotated: true) }

      it "annotates the stage" do
        expect(subject).to eq(
          '<span class="publisher">ISO</span>/<span class="stage">CD</span>' \
          ' <span class="docnumber">1234</span>'
        )
      end
    end

    describe "ISO identifier with stage and type prefix" do
      subject { Identifier.parse("ISO/DTR 1234").to_s(annotated: true) }

      it "renders without raising and annotates the document number" do
        expect { subject }.not_to raise_error
        expect(subject).to include('<span class="docnumber">1234</span>')
      end
    end

    describe "without annotation (default)" do
      subject { Identifier.parse("ISO 1234-1:2013").to_s }

      it "renders without span tags" do
        expect(subject).to eq("ISO 1234-1:2013")
      end
    end

    describe "annotated: false explicitly" do
      subject { Identifier.parse("ISO 1234-1:2013").to_s(annotated: false) }

      it "renders without span tags" do
        expect(subject).to eq("ISO 1234-1:2013")
      end
    end
  end
end
