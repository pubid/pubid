# frozen_string_literal: true

# The cen_pfs parity gate (pubid/pubid#706 §4 + pubid-grammar#121): the
# PFS-compiled `cen_pfs` flavor versus the coded `Pubid::CenCenelec` over
# the FULL corpus inventory (189 pass rows, every payload file). Drift is
# a defect in the DEFINITION (pubid-grammar's definitions/cen.pfs) or the
# compiler — never a reason to relax an expectation here.
#
# Measured parity, per surface (2026-11, parsanol 1.3.126, compiler with
# the six #121 declared-emission features):
#
#   absorb        189 / 189  (100% — the phase-2 composition carried 55;
#                 the 134 pinned rows absorbed on the six features:
#                 multi-type emission, the prEN/FprEN draft stages, cen's
#                 wrapper shapes, the adopted-base dispatch, the
#                 publisher-type defaults, the fused URN segments)
#   to_s          the canonical face renders the printed form — the head
#                 dispatch (draft / Guide word / adopted / publisher),
#                 presence-guarded tails, the printed run and the FRAG face
#   to_hash       the shared serialization tables (flat publisher/
#                 copublishers scalars, the date flattened to `year`, the
#                 draft stage compacted to "stage" => "pren"), byte-identical
#   to_urn        the declared fused segments — the publisher group
#                 ("cen-clc-etsi"), the adopted MR string with its
#                 separators fused to colons, the composed code, the year,
#                 the stage code, the wrapper chains (:amd:/:cor:/:frag:)
#                 and the consolidated :plus: marker
#   to_pubid_urn  purn parity rides hash parity: the alias's hash carries
#                 the scheme's canonical _type, so it encodes through the
#                 coded schema
#   to_mr_string  the declared MR hooks (number-part join, the year), the
#                 draft mr_type override and the wrapper suffixes
#
# A row the compiled flavor does NOT absorb fails this spec — the ledger
# below pins the per-file row totals (the corpus files' conservation), so
# a corpus addition or a regression turns it red and forces a conscious
# ledger update.

require "spec_helper"
require "pubid/conformance"

RSpec.describe "Pubid::CenPfs parity with the coded Pubid::CenCenelec" do
  corpus_repo = ENV.fetch("PUBID_TESTSUITE_PATH",
                          File.expand_path("../../../../pubid-testsuite", 
                                           __dir__))
  corpus_dir = File.join(corpus_repo, "tests")
  corpus_present = File.directory?(File.join(corpus_dir, "cen_cenelec"))
  before do
    skip "pubid-testsuite corpus absent" unless corpus_present
    Pubid.eager_load_flavors!
  end

  files = if corpus_present
            Dir[File.join(corpus_dir, "cen_cenelec", "*.yaml")]
              .reject { |p| File.basename(p).start_with?("_") }.sort
          else
            []
          end

  # rows grouped per payload file: [test_case, absorbed?] — the absorbed?
  # half exists so a regression that un-absorbs a row reports WHERE; at
  # full absorption every row sits in the first group.
  measured = Hash.new { |h, k| h[k] = { absorbed: [], unabsorbed: [] } }
  files.each do |path|
    fname = File.basename(path, ".yaml")
    Pubid::Conformance::Corpus.load_file(path).each do |test_case|
      next if test_case.review? || test_case.quarantined? || test_case.error_case?

      begin
        Pubid::CenPfs.parse(test_case.representations.human)
        measured[fname][:absorbed] << test_case
      rescue Pubid::Errors::ParseError
        measured[fname][:unabsorbed] << test_case
      end
    end
  end

  # Per-row gates: byte parity on every surface where absorbed, rejection
  # where not (none — the definition absorbs the whole declared surface).
  measured.each do |fname, groups|
    groups[:absorbed].each do |test_case|
      input = test_case.representations.human

      it "[#{fname}] #{test_case.id} (#{input.inspect}) agrees byte-for-byte " \
         "with the coded flavor on every identity surface" do
        coded = Pubid::CenCenelec.parse(input)
        pfs = Pubid::CenPfs.parse(input)

        expect(pfs.class).not_to eq(coded.class)
        expect(pfs.class.name.split("::").last).to eq(coded.class.name.split("::").last)
        expect(pfs.to_s).to eq(coded.to_s)
        expect(pfs.to_hash).to eq(coded.to_hash)
        expect(pfs.to_urn).to eq(coded.to_urn)
        expect(pfs.to_pubid_urn).to eq(coded.to_pubid_urn)
        expect(pfs.to_mr_string).to eq(coded.to_mr_string)
      end

      it "[#{fname}] #{test_case.id} round-trips through its own from_hash" do
        pfs = Pubid::CenPfs.parse(input)
        expect(Pubid::CenPfs::Identifier.from_hash(pfs.to_hash)).to eq(pfs)
      end
    end

    groups[:unabsorbed].each do |test_case|
      input = test_case.representations.human
      it "[#{fname}] #{test_case.id} (#{input.inspect}) stays outside the declared surface" do
        # the compiled flavor must not accept what its model cannot
        # represent — accepting without representing is the silent
        # failure this harness exists to prevent
        expect { Pubid::CenPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  # The ledger: the measured boundary, pinned per payload file. The six
  # #121 features absorb every row; the counts stand for the corpus
  # conservation, so a new payload file (or a new row in one) must enter
  # the ledger consciously.
  LEDGER = {
    "adopted_european_norm" => 17,
    "amendment" => 15,
    "cen_report" => 22,
    "cen_workshop_agreement" => 1,
    "consolidated_identifier" => 18,
    "corrigendum" => 14,
    "european_norm" => 67,
    "european_prestandard" => 7,
    "european_specification" => 2,
    "fragment" => 1,
    "guide" => 11,
    "harmonization_document" => 3,
    "technical_report" => 7,
    "technical_specification" => 4,
  }.freeze

  it "the measured absorption matches the pinned ledger" do
    actual = measured.to_h do |fname, groups|
      [fname, groups[:absorbed].size + groups[:unabsorbed].size]
    end
    expect(actual).to eq(LEDGER)
    # the ledger covers every payload file: a new corpus file must enter
    # the ledger consciously, like a new row
    expect(actual.keys).to match_array(LEDGER.keys)
  end

  it "absorbs every corpus row byte-identically (zero rows pinned)" do
    absorbed_total = measured.values.sum { |g| g[:absorbed].size }
    unabsorbed_total = measured.values.sum { |g| g[:unabsorbed].size }
    expect(absorbed_total).to eq(189)
    expect(unabsorbed_total).to be_zero
  end

  # The former gaps, now features (pubid-grammar#121). Each pins one of
  # the six declared-emission features on a real corpus row.
  describe "the former gaps, now features" do
    it "multi-type emission: the deliverable families are declared types" do
      {
        "CEN/TR 12101-5:2005" => Pubid::CenPfs::Identifiers::TechnicalReport,
        "CEN/TS 17638:2021" => Pubid::CenPfs::Identifiers::TechnicalSpecification,
        "CR 10313:2000" => Pubid::CenPfs::Identifiers::CenReport,
        "CWA 14050-21:2000" => Pubid::CenPfs::Identifiers::CenWorkshopAgreement,
        "ES 59008-1:2000" => Pubid::CenPfs::Identifiers::EuropeanSpecification,
        "ENV 1613:1995" => Pubid::CenPfs::Identifiers::EuropeanPrestandard,
        "HD 1215-2:1988" => Pubid::CenPfs::Identifiers::HarmonizationDocument,
        "CEN Guide 414:2017" => Pubid::CenPfs::Identifiers::Guide,
        "EN 1325" => Pubid::CenPfs::Identifiers::EuropeanNorm,
      }.each do |input, klass|
        expect(Pubid::CenPfs.parse(input)).to be_a(klass)
        expect(Pubid::CenPfs.parse(input).to_hash)
          .to eq(Pubid::CenCenelec.parse(input).to_hash)
      end
    end

    it "draft-stage serialization: a prEN/FprEN row carries the compact stage code" do
      pren = Pubid::CenPfs.parse("prEN 12464-1:2019")
      expect(pren.to_hash["stage"]).to eq("pren")
      expect(pren.to_s).to eq("prEN 12464-1:2019")
      expect(pren.to_urn).to eq("urn:cen:en:12464-1:2019:stage.proposal")
      expect(pren.to_mr_string).to eq("en.pren.12464-1.2019")

      fpren = Pubid::CenPfs.parse("FprEN 50600-2-4")
      expect(fpren.to_hash["stage"]).to eq("fpren")
      expect(fpren.to_urn).to eq("urn:cen:en:50600-2-4:stage.final_proposal")
    end

    it "wrapper shapes: the slash run is a standalone amendment, the plus " \
       "run a consolidated bundle, the unnumbered AC a corrigendum" do
      amd = Pubid::CenPfs.parse("EN 13250:2000/A1:2005")
      expect(amd).to be_a(Pubid::CenPfs::Identifiers::Amendment)
      expect(amd.number).to eq("1")
      expect(amd.year).to eq("2005")
      expect(amd.base).to be_a(Pubid::CenPfs::Identifiers::EuropeanNorm)
      expect(amd.to_s).to eq("EN 13250:2000/A1:2005")
      expect(amd.to_urn).to eq("urn:cen:en:13250:2000:amd:1:2005")

      consolidated = Pubid::CenPfs.parse("EN 285:2015+A1")
      expect(consolidated).to be_a(Pubid::CenPfs::Identifiers::ConsolidatedIdentifier)
      expect(consolidated.identifiers.first).to be_a(Pubid::CenPfs::Identifiers::EuropeanNorm)
      expect(consolidated.to_mr_string).to eq("en.285.2015_plus-amd.1")

      unnumbered = Pubid::CenPfs.parse("EN 13254:2000/AC:2003")
      expect(unnumbered).to be_a(Pubid::CenPfs::Identifiers::Corrigendum)
      expect(unnumbered.number).to be_nil
      expect(unnumbered.year).to eq("2003")

      dated = Pubid::CenPfs.parse("EN 61375-2-3:2015/AC:2016-11")
      expect(dated.month).to eq("11")
      expect(dated.to_urn).to eq("urn:cen:en:61375-2-3:2015:cor:2016-11")
    end

    it "adopted-base dispatch: the hook parses the adopted run with the owning flavor" do
      iso = Pubid::CenPfs.parse("EN ISO 12100:2010")
      expect(iso).to be_a(Pubid::CenPfs::Identifiers::AdoptedEuropeanNorm)
      expect(iso.adopted).to be_a(Pubid::Iso::Identifier)
      expect(iso.to_hash).to eq(Pubid::CenCenelec.parse("EN ISO 12100:2010").to_hash)
      expect(iso.to_urn).to eq("urn:cen:en:iso:12100:2010")

      iec = Pubid::CenPfs.parse("EN IEC 62115:2020")
      expect(iec.adopted).to be_a(Pubid::Iec::Identifier)

      env = Pubid::CenPfs.parse("ENV ISO 11079:1999")
      expect(env).to be_a(Pubid::CenPfs::Identifiers::EuropeanPrestandard)
      expect(env.adopted).to be_a(Pubid::Iso::Identifier)
    end

    it "publisher-type defaults: the designation types default the publisher column" do
      # the publisher equals its default, so to_hash drops it
      expect(Pubid::CenPfs.parse("CR 10313:2000").to_hash).not_to include("publisher")
      expect(Pubid::CenPfs.parse("CWA 14050-21:2000").to_hash).not_to include("publisher")
      # the captured publisher survives
      expect(Pubid::CenPfs.parse("CEN/TR 12101-5:2005").to_hash["publisher"]).to eq("CEN")
      expect(Pubid::CenPfs.parse("CR 10313:2000").to_mr_string).to eq("cr.10313.2000")
    end

    it "fused URN segments: the publisher group and the adopted MR fuse" do
      expect(Pubid::CenPfs.parse("CEN/CLC/ETSI/TR 101551:2026").to_urn)
        .to eq("urn:cen:cen-clc-etsi:101551:2026")
      expect(Pubid::CenPfs.parse("CEN ISO/TS 21003-7:2008").to_urn)
        .to eq("urn:cen:cen:iso:ts:21003-7:2008")
      consolidated_adoption = Pubid::CenPfs.parse("EN ISO 10077-1:2006+AC:2009+AC2:2009")
      expect(consolidated_adoption.to_urn)
        .to eq("urn:cen:en:iso:10077-1:2006:plus:cor:2009:plus:cor:2:2009")
      expect(Pubid::CenPfs.parse("EN 60038/A1 FRAG2").to_urn)
        .to eq("urn:cen:en:60038:amd:1:frag:2")
    end
  end

  describe "the declared negatives (both flavors reject)" do
    '
      nonsense
      ETSI EN 300 175
      CEN/XX 100
      HD 1215-2:198
      EN ISO
      EN 300 175 V
      EN 1325 EXTRA
      EN A1
      ISO 12100:2010
      EN 1325:20000
      EN /TR 100
      EN 13250:2000/A1:
      EN 13250:2000/ACX:2003
      EN 285:2015+A1:
      FRAG2
      EN 13250:2000 FRAG2
    '.split("\n").map(&:strip).reject(&:empty?).each do |input|
      it "rejects #{input.inspect} with the coded flavor's ParseError" do
        expect { Pubid::CenCenelec.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
        expect { Pubid::CenPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  it "shares the input guards with the coded flavor" do
    [Pubid::CenCenelec, Pubid::CenPfs].each do |flavor|
      expect { flavor.parse(42) }
        .to raise_error(Pubid::Errors::InvalidInputError, Pubid::INPUT_NOT_A_STRING_MESSAGE)
      expect { flavor.parse("x" * (Pubid::MAX_INPUT_LENGTH + 1)) }
        .to raise_error(Pubid::Errors::InvalidInputError,
                        Pubid::INPUT_TOO_LONG_MESSAGE)
    end
  end

  it "never hijacks Pubid.parse — the coded flavor keeps routing CEN" do
    expect(Pubid.parse("EN 12464-1:2011")).to be_a(Pubid::CenCenelec::Identifier)
  end

  it "registers beside the coded flavor (coexistence, not cutover)" do
    expect(Pubid::Registry.registered?(:cen_cenelec)).to be(true)
    expect(Pubid::Registry.registered?(:cen_pfs)).to be(true)
    # the dev alias declares the scheme-canonical namespace, so its URN
    # generator pins the cen namespace while its schema registers under
    # its own key
    expect(Pubid::CenPfs::UrnGenerator.new(nil).urn_namespace).to eq("cen")
    expect(Pubid::PubidUrn.flavor_schema("cen_pfs")).not_to be_nil
    expect(Pubid::PubidUrn.flavor_schema("cencenelec")).not_to be_nil
  end
end
