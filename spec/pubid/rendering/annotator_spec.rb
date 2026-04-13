# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Rendering::Annotator do
  describe ".annotate" do
    context "with simple ISO identifier" do
      let(:id) { Pubid::Iso.parse("ISO 9001:2015") }

      it "wraps publisher in publisher span" do
        expect(id.annotated).to include('<span class="publisher">ISO</span>')
      end

      it "wraps docnumber in docnumber span" do
        expect(id.annotated).to include('<span class="docnumber">9001</span>')
      end

      it "wraps year in year span" do
        expect(id.annotated).to include('<span class="year">2015</span>')
      end

      it "preserves separators outside spans" do
        expect(id.annotated).to eq(
          '<span class="publisher">ISO</span> ' \
          '<span class="docnumber">9001</span>:' \
          '<span class="year">2015</span>',
        )
      end
    end

    context "with part number" do
      let(:id) { Pubid::Iso.parse("ISO 19115-1:2014") }

      it "wraps part separately from docnumber" do
        expect(id.annotated).to eq(
          '<span class="publisher">ISO</span> ' \
          '<span class="docnumber">19115</span>-' \
          '<span class="part">1</span>:' \
          '<span class="year">2014</span>',
        )
      end
    end

    context "with copublishers (ISO/IEC)" do
      let(:id) { Pubid::Iso.parse("ISO/IEC 27001:2013") }

      it "wraps the leading publisher and leaves IEC inline" do
        # Annotator only wraps verbatim publisher.body matches; copublisher
        # tagging is a future extension.
        expect(id.annotated).to start_with('<span class="publisher">ISO</span>/IEC ')
      end
    end

    context "with multi-level supplement" do
      let(:id) { Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020") }

      it "annotates both base and supplement components" do
        result = id.annotated
        expect(result).to include('<span class="docnumber">9001</span>')
        expect(result).to include('<span class="year">2015</span>')
        expect(result).to include('<span class="docnumber">1</span>')
        expect(result).to include('<span class="year">2020</span>')
      end

      it "does not let supplement number land inside base number" do
        # Regression: an earlier draft wrapped "1" inside "9001".
        expect(id.annotated).not_to include('900<span class="docnumber">1</span>')
      end
    end

    context "with IEC identifier (flavor-agnostic chokepoint)" do
      let(:id) { Pubid::Iec.parse("IEC 60050:2011") }

      it "wraps publisher, docnumber, and year" do
        expect(id.annotated).to eq(
          '<span class="publisher">IEC</span> ' \
          '<span class="docnumber">60050</span>:' \
          '<span class="year">2011</span>',
        )
      end
    end
  end
end
