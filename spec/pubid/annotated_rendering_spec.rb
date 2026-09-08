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

  # The types whose `to_s` composes its own string instead of going through
  # `render`. They accept the flag (the block above proves that) and used to
  # answer with plain text, because the shared annotation hook sits inside
  # `render` and they never reach it.
  #
  # The table is keyed by CLASS, not by flavor. A per-flavor table is exactly
  # how all 36 of these read as covered: `REFS` above holds one reference per
  # flavor, and for csa, ieee, nist and ccsds that reference happens to be a
  # type that DOES annotate, so the sibling types went unmeasured.
  #
  # Each reference is taken from that flavor's own pass fixtures.
  describe "types that compose their own string" do
    HAND_COMPOSED = [
      ["Pubid::Ccsds::Identifiers::Corrigendum", "ccsds", "CCSDS 121.0-B-1-S Cor. 1"],
      ["Pubid::Cie::Identifiers::Bundle", "cie",
       "CIE 198-SP1.1:2011,198-SP1.2:2011,198-SP1.3:2011,198-SP1.4:2011"],
      ["Pubid::Cie::Identifiers::Conference", "cie", "CIE x005-1992"],
      ["Pubid::Cie::Identifiers::Corrigendum", "cie", "CIE 198-SP1.4:2011/Cor1:2013"],
      ["Pubid::Cie::Identifiers::DualPublished", "cie", "CIE S 009:2002/IEC 62471:2006"],
      ["Pubid::Cie::Identifiers::Identical", "cie", "CIE S 006.1/1998 (ISO 16508:1999)"],
      ["Pubid::Cie::Identifiers::JointPublished", "cie", "CIE ISO 10916:2024"],
      ["Pubid::Cie::Identifiers::Proceedings", "cie", "CIE x043-OP01"],
      ["Pubid::Cie::Identifiers::Standard", "cie", "CIE S 004/E-2001"],
      ["Pubid::Cie::Identifiers::Supplement", "cie", "CIE 121-SP1:2009"],
      ["Pubid::Cie::Identifiers::TutorialBundle", "cie", "CIE Tutorials Bundle 1"],
      ["Pubid::Csa::Identifiers::Bundled", "csa",
       "CAN/CSA-C22.2 NO. 60601-1-6:11 + A1:15 + A2:21 (R2021) (CONSOLIDATED)"],
      ["Pubid::Csa::Identifiers::CanadianAdopted", "csa", "CAN/CSA-A123.2-03 (R2023)"],
      ["Pubid::Csa::Identifiers::Combined", "csa", "CSA A23.1:24/CSA A23.2:24"],
      ["Pubid::Csa::Identifiers::CsaAdopted", "csa", "CSA ISO/IEC 8824-1:22"],
      ["Pubid::Csa::Identifiers::Package", "csa",
       "CSA B149.1:25 Code, Handbook & Training Package"],
      ["Pubid::Ieee::Aiee::Identifier", "ieee",
       "AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)"],
      ["Pubid::Ieee::Identifiers::JointDevelopment", "ieee", "IEC/IEEE P60780-323, CDV1 2014"],
      ["Pubid::Ieee::Identifiers::Nesc::Edition", "ieee",
       "2017 National Electrical Safety Code(R) (NESC(R))"],
      ["Pubid::Ieee::Identifiers::Nesc::Handbook", "ieee", "2012 NESC Handbook, Seventh Edition"],
      ["Pubid::Ieee::Identifiers::Nesc::Standard", "ieee",
       "C2-1997 National Electric Safety Code (NESC)"],
      ["Pubid::Ieee::Ire::Identifier", "ieee", "52 IRE 7.S2"],
      ["Pubid::Itu::Identifiers::Addendum", "itu", "ITU-T I.363 (1993) Add. 1 (11/1993)"],
      ["Pubid::Itu::Identifiers::Amendment", "itu", "ITU-T G.722.2 App. I (2002) Amd. 1 (07/2003)"],
      ["Pubid::Itu::Identifiers::Corrigendum", "itu", "ITU-T G.729 Annex B (1996) Cor. 3 (03/2001)"],
      ["Pubid::Itu::Identifiers::Errata", "itu", "ITU-T G.722.2 Annex B (2002) Err. 1 (07/2003)"],
      ["Pubid::Itu::Identifiers::Supplement", "itu", "ITU-T V.25 ter Suppl. 1 (04/1995)"],
      ["Pubid::Nist::Identifiers::CommercialStandardsMonthly", "nist", "NBS CSM 1"],
      ["Pubid::Nist::Identifiers::CrplReport", "nist", "NBS CRPL 1-1"],
      ["Pubid::Nist::Identifiers::InteragencyReport", "nist", "NBS IR 73-101"],
      ["Pubid::Nist::Identifiers::MiscellaneousPublication", "nist", "NBS MP 1"],
      ["Pubid::Nist::Identifiers::Monograph", "nist", "NBS MONO 1"],
      ["Pubid::Nist::Identifiers::Report", "nist", "NBS RPT 10003"],
    ].freeze

    # Two more reach the hook already and were plain for a different reason:
    # the annotator found none of their component values in the string. They
    # are here because the fix is the same branch, not the same edit.
    VALUE_MATCH = [
      ["Pubid::Csa::Identifiers::Cec", "csa", "CSA C22.2 NO. 286:23"],
      ["Pubid::Iec::Identifiers::WorkingDocument", "iec", "1/2457/FDIS"],
    ].freeze

    (HAND_COMPOSED + VALUE_MATCH).each do |class_name, flavor, ref|
      context "#{class_name} (#{ref})" do
        let(:id) { Pubid::Registry.get(flavor).parse(ref) }

        # Guards the table itself: a grammar change that re-routes the
        # reference to another class would otherwise leave this example
        # passing while the named class went unmeasured again.
        it "parses to #{class_name}" do
          expect(id.class.name).to eq(class_name)
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
  end

  # ASTM's technical report prints with no separators at all —
  # "ISO/ASTMTR52952-EB" — so although the identifier does carry
  # publisher "ISO/ASTM" and number "52952", both sit against a word
  # character in the output. `Annotator#standalone?` refuses a match in that
  # position, and that refusal is the rule that stops the part "1" of
  # "ISO 1234-1" binding inside "1234". Annotating this form would mean
  # relaxing the rule for every flavor.
  #
  # So it stays plain, deliberately, and this example says so. If a later
  # change makes it annotate, the example turns red — which is the signal to
  # check WHY, not to delete it.
  describe "a glued rendering has no annotatable token" do
    let(:id) { Pubid::Astm.parse("ISO/ASTMTR52952-EB") }

    it "carries the values" do
      expect(id.publisher).to eq("ISO/ASTM")
      expect(id.number).to eq("52952")
    end

    it "renders plain even under the flag, because none of them stands alone" do
      expect(id.to_s(annotated: true)).to eq("ISO/ASTMTR52952-EB")
    end
  end

# A `to_s` that post-processes the string it got from an annotating `super`
# must post-process FIRST. NIST's circular and handbook rewrite the edition
# token with a `$`-anchored regex; once the string ends in "</span>" the
# anchor cannot match and the rewrite silently stops applying.
#
# Asserting the OUTPUT cannot catch this today: for both references the
# annotator happens to match only the leading publisher, so the tail is bare
# and the anchored regex still fires. The ordering is what is under test, so
# the ordering is what this asserts — the string handed to the annotation
# must already be rewritten, and must carry no span.
describe "post-processing runs before annotation, not after" do
  {
    "NBS CIRC 11e2-1915" => "11e2.1915",
    "NBS HB 44e2-1955" => "44e2-1955",
  }.each do |ref, rewritten|
    it "annotates the already-rewritten string for #{ref}" do
      id = Pubid::Nist.parse(ref)
      handed = nil

      allow(id).to receive(:annotate_plain_render).and_wrap_original do |orig, rendered, **opts|
        handed = rendered
        orig.call(rendered, **opts)
      end

      id.to_s(annotated: true)

      expect(handed).to include(rewritten)
      expect(handed).not_to include("<span")
    end
  end
end

end
