# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# `to_s(annotated: true)` wraps each sub-token of a rendered identifier in a
# semantic <span class="..."> for downstream CSS styling (isodoc's
# std_docid_semantic_parse). Downstream HTML keys on those classes, so losing
# them is a visible regression, not a fixture drift.
#
# In pubid 1.x annotation lived in ONE line of the shared core
# (pubid-core's Renderer::Base#prerender_params), so every flavor got it free.
# In pubid 2 the `annotate` helper is private on Renderers::Base and only the
# HumanReadable family calls it — all 39 flavor renderers receive
# `context.annotated` and ignore it. This spec is the cross-flavor lock that
# was missing: the single existing annotated spec covers ISO only, which is
# exactly how 38 flavors read as covered while emitting plain text.
RSpec.describe "annotated rendering (cross-flavor)" do
  # One representative reference per flavor that has a renderer of its own.
  # The assertion is deliberately structural — "some token got a span, and
  # stripping the spans returns the plain rendering" — not a byte-exact
  # expectation per flavor, so the table does not need rewriting whenever a
  # renderer's spacing changes.
  REFS = {
    "iso" => "ISO 1234-1:2013",
    "iec" => "IEC 60038:2009",
    "ieee" => "IEEE Std 802.11-2020",
    "nist" => "NIST SP 800-53",
    "itu" => "ITU-T G.711",
    "bsi" => "BS 5555:1981",
    "etsi" => "ETSI EN 300 175-1 V2.1.1",
    "jis" => "JIS B 0001:2019",
    "gost" => "GOST 1234-56",
    "cen_cenelec" => "EN 1234:2018",
    "jcgm" => "JCGM 100:2008",
    "ccsds" => "CCSDS 121.0-B-2",
    "ecma" => "ECMA-262",
    "oasis" => "OASIS EDXL",
    "w3c" => "W3C REC-xml-20081126",
    "ogc" => "OGC 06-121r9",
    "iho" => "IHO S-57",
    "sae" => "SAE J300:2019",
    "csa" => "CSA B149.1:20",
    "astm" => "ASTM A1-18",
    "asme" => "ASME B16.5-2020",
    "3gpp" => "3GPP TS 04.01",
  }.freeze

  def strip_spans(str)
    str.gsub(%r{</?span[^>]*>}, "")
  end

  it "covers a representative reference for the major flavors" do
    expect(REFS.keys).to all(satisfy { |f| Pubid::Registry.registered?(f) })
  end

  REFS.each do |flavor_name, ref|
    context "#{flavor_name} (#{ref})" do
      let(:mod) { Pubid::Registry.get(flavor_name) }
      let(:id) { mod.parse(ref) }

      it "does not raise on the annotated flag" do
        expect { id.to_s(annotated: true) }.not_to raise_error
      end

      it "emits at least one semantic span" do
        expect(id.to_s(annotated: true)).to include("<span class=")
      end

      it "is byte-identical to the plain rendering once spans are stripped" do
        expect(strip_spans(id.to_s(annotated: true))).to eq(id.to_s)
      end

      it "emits no span by default" do
        expect(id.to_s).not_to include("<span")
      end
    end
  end

  # `to_s` is defined 62 times across the gem in incompatible shapes. Before
  # the AnnotatedToS wrapper, 13 type families REJECTED the flag outright —
  # `wrong number of arguments (given 1, expected 0)` for the 28 wrapper and
  # supplement types whose `to_s` takes no parameters, and
  # `unknown keyword: :annotated` for the closed keyword lists. A raise is
  # worse than a missing span: a wrapper is exactly the shape a consumer
  # renders.
  #
  # A corpus sweep over one identifier of every concrete type puts this at
  # 214 types annotating and 0 raising, against 9 that render plain (CSA and
  # CIE containers, IEC WorkingDocument, ASTM TechnicalReport — wrappers whose
  # own component values do not appear in the string they delegate).
  describe "no type rejects the flag" do
    [
      "ISO/IEC DIR 1:2022 + IEC SUP:2022",
      "ISO 1234:2000/Amd 1:2005",
      "IEC 60050:2001+AMD1:2005 CSV",
      "CIE 198:2011",
      "CSA B149.1:20",
      "ITU-T G.711",
      "CCSDS 121.0-B-2",
    ].each do |ref|
      it "does not raise for #{ref}" do
        expect { Pubid.parse(ref).to_s(annotated: true) }.not_to raise_error
      end
    end

    # Every identifier `to_s` must accept the flag, whatever its signature.
    # 37 classes across 6 flavors did not: 25 declared no parameters at all
    # and raised `wrong number of arguments (given 1, expected 0)`, IEEE's
    # JointDevelopment had a closed keyword list, and NIST's 11 take a
    # positional `format`. This asserts the property directly on every loaded
    # class, rather than on one example that could drift.
    it "is accepted by every identifier class that defines to_s" do
      # Force-load every identifier class, including the ones nested a level
      # deeper than `Identifiers::` — IEEE's `Nesc::` and `Ire::` families live
      # there, and a shallow scan reported them clean while all six still
      # raised on the flag.
      load_identifier_classes = lambda do |namespace, depth|
        return if depth > 2

        namespace.constants.each do |const|
          value = begin
            namespace.const_get(const)
          rescue StandardError, ScriptError
            next
          end
          load_identifier_classes.call(value, depth + 1) if value.is_a?(Module)
        end
      end

      Pubid::Registry.flavor_names.each do |flavor|
        load_identifier_classes.call(Pubid::Registry.get(flavor), 0)
      end

      offenders = ObjectSpace.each_object(Class).select do |klass|
        next false unless klass < Pubid::Identifier
        next false unless klass.instance_methods(false).include?(:to_s)

        params = klass.instance_method(:to_s).parameters
        params.none? do |type, name|
          type == :keyrest || (%i[key keyreq].include?(type) && name == :annotated) ||
            type == :opt
        end
      end

      expect(offenders.map(&:name)).to be_empty
    end
  end

  # The class names are the v1 vocabulary; downstream CSS keys on them, so a
  # rename is a breaking change and belongs in a failing test.
  describe "class vocabulary" do
    it "uses the v1 names for an ISO identifier" do
      annotated = Pubid::Iso.parse("ISO/DIS 10303-62").to_s(annotated: true)

      expect(annotated).to eq(
        '<span class="publisher">ISO</span>/<span class="stage">DIS</span> ' \
        '<span class="docnumber">10303</span>-<span class="part">62</span>',
      )
    end

    it "uses the same names for a flavor with its own renderer (IEC)" do
      annotated = Pubid::Iec.parse("IEC 60038:2009").to_s(annotated: true)

      expect(annotated).to include('<span class="publisher">IEC</span>')
      expect(annotated).to include('<span class="docnumber">60038</span>')
      expect(annotated).to include('<span class="year">2009</span>')
    end
  end
end
