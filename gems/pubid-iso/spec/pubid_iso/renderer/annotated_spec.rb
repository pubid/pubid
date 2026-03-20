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
