# frozen_string_literal: true

require "rspec"
require_relative "../../../../lib/pubid/iso"

# Annotated rendering wraps each docid sub-token in a semantic
# <span class="…"> for downstream CSS styling (isodoc's
# std_docid_semantic_parse). This is the v2 port of the v1-only feature
# (issue #71). Coverage deliberately includes staged identifiers from the
# start — the v1 spec only covered a type-prefix id, which let a
# staged-identifier crash ship (#69 / #70).
RSpec.describe "annotated rendering" do
  def annotated(str, **opts)
    Pubid::Iso.parse(str).to_s(annotated: true, **opts)
  end

  describe "byte-for-byte parity with v1 (issue examples)" do
    it "renders a staged, parted identifier" do
      expect(annotated("ISO/DIS 10303-62")).to eq(
        '<span class="publisher">ISO</span>/<span class="stage">DIS</span> ' \
        '<span class="docnumber">10303</span>-<span class="part">62</span>',
      )
    end

    it "renders a copublished type-prefix identifier with year" do
      expect(annotated("ISO/IEC TR 2131:2013")).to eq(
        '<span class="publisher">ISO/IEC</span> <span class="doctype">TR</span> ' \
        '<span class="docnumber">2131</span>:<span class="year">2013</span>',
      )
    end

    it "renders publisher, number, part and year" do
      expect(annotated("ISO 1234-1:2013")).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">1234</span>' \
        '-<span class="part">1</span>:<span class="year">2013</span>',
      )
    end

    it "renders triple copublisher with type, part and year" do
      expect(annotated("ISO/IEC/IEEE TR 2131-1:2013")).to eq(
        '<span class="publisher">ISO/IEC/IEEE</span> <span class="doctype">TR</span> ' \
        '<span class="docnumber">2131</span>-<span class="part">1</span>:' \
        '<span class="year">2013</span>',
      )
    end
  end

  describe "staged identifiers annotate the stage with class=\"stage\"" do
    {
      "ISO/DIS 1234" => "DIS",
      "ISO/FDIS 1234" => "FDIS",
      "ISO/CD 1234" => "CD",
      "ISO/WD 1234" => "WD",
      "ISO/AWI 1234" => "AWI",
      "ISO/NP 1234" => "NP",
    }.each do |input, abbr|
      it "wraps #{abbr} as a stage" do
        expect(annotated(input)).to eq(
          '<span class="publisher">ISO</span>/' \
          "<span class=\"stage\">#{abbr}</span> " \
          '<span class="docnumber">1234</span>',
        )
      end
    end
  end

  describe "type-prefix identifiers annotate the type with class=\"doctype\"" do
    it "renders a draft technical report (DTR) as a doctype" do
      expect(annotated("ISO/DTR 1234")).to eq(
        '<span class="publisher">ISO</span>/<span class="doctype">DTR</span> ' \
        '<span class="docnumber">1234</span>',
      )
    end

    it "renders a technical specification (TS) as a doctype" do
      expect(annotated("ISO/TS 1234")).to eq(
        '<span class="publisher">ISO</span>/<span class="doctype">TS</span> ' \
        '<span class="docnumber">1234</span>',
      )
    end
  end

  describe "combinations" do
    it "renders stage + part + year" do
      expect(annotated("ISO/DIS 10303-62:2020")).to eq(
        '<span class="publisher">ISO</span>/<span class="stage">DIS</span> ' \
        '<span class="docnumber">10303</span>-<span class="part">62</span>:' \
        '<span class="year">2020</span>',
      )
    end

    it "renders copublisher + stage (space separator)" do
      expect(annotated("ISO/IEC DIS 23456")).to eq(
        '<span class="publisher">ISO/IEC</span> <span class="stage">DIS</span> ' \
        '<span class="docnumber">23456</span>',
      )
    end

    it "annotates the edition" do
      expect(annotated("ISO 1234:2013 ED1", with_edition: true)).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">1234</span>:' \
        '<span class="year">2013</span> <span class="edition">ED1</span>',
      )
    end

    it "annotates a single-char language code" do
      expect(annotated("ISO 1234:2013(E)", lang_single: true)).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">1234</span>:' \
        '<span class="year">2013</span>(<span class="language">E</span>)',
      )
    end
  end

  describe "supplements (amendment / corrigendum / addendum)" do
    it "annotates an amendment, recursively annotating the base id" do
      expect(annotated("ISO 1234:2000/Amd 1:2005")).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">1234</span>:' \
        '<span class="year">2000</span>/<span class="amendment">Amd</span> ' \
        '<span class="docnumber">1</span>:<span class="year">2005</span>',
      )
    end

    it "annotates a draft amendment" do
      expect(annotated("ISO 9001:2015/DAmd 1:2020")).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">9001</span>:' \
        '<span class="year">2015</span>/<span class="amendment">DAmd</span> ' \
        '<span class="docnumber">1</span>:<span class="year">2020</span>',
      )
    end

    it "annotates a corrigendum" do
      expect(annotated("ISO 1234:2000/Cor 1:2005")).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">1234</span>:' \
        '<span class="year">2000</span>/<span class="corrigendum">Cor</span> ' \
        '<span class="docnumber">1</span>:<span class="year">2005</span>',
      )
    end

    it "annotates an addendum" do
      expect(annotated("ISO 1234:2000/Add 1")).to eq(
        '<span class="publisher">ISO</span> <span class="docnumber">1234</span>:' \
        '<span class="year">2000</span>/<span class="addendum">Add</span> ' \
        '<span class="docnumber">1</span>',
      )
    end
  end

  describe "subclass renderers" do
    it "annotates a directives identifier" do
      expect(annotated("ISO/IEC DIR 1")).to eq(
        '<span class="publisher">ISO/IEC</span> <span class="doctype">DIR</span> ' \
        '<span class="docnumber">1</span>',
      )
    end

    it "annotates a guide identifier" do
      expect(annotated("ISO/IEC GUIDE 99:2007")).to eq(
        '<span class="publisher">ISO/IEC</span> <span class="doctype">Guide</span> ' \
        '<span class="docnumber">99</span>:<span class="year">2007</span>',
      )
    end

    it "annotates an IWA identifier (no publisher token)" do
      expect(annotated("IWA 5:2010")).to eq(
        '<span class="doctype">IWA</span> <span class="docnumber">5</span>:' \
        '<span class="year">2010</span>',
      )
    end
  end

  describe "no annotation by default (regression guard)" do
    it "emits no spans for plain to_s" do
      expect(Pubid::Iso.parse("ISO 1234-1:2013").to_s).not_to include("<span")
    end

    it "emits no spans for to_s(annotated: false)" do
      expect(Pubid::Iso.parse("ISO/DIS 10303-62").to_s(annotated: false))
        .not_to include("<span")
    end

    it "produces identical text content with and without annotation" do
      %w[
        ISO/DIS\ 10303-62 ISO/IEC\ TR\ 2131:2013 ISO\ 1234:2000/Amd\ 1:2005
        ISO/IEC\ DIR\ 1 IWA\ 5:2010
      ].each do |input|
        plain = Pubid::Iso.parse(input).to_s
        stripped = Pubid::Iso.parse(input).to_s(annotated: true)
          .gsub(%r{</?span[^>]*>}, "")
        expect(stripped).to eq(plain)
      end
    end
  end
end
