# frozen_string_literal: true

# The cen_pfs measurement harness (pubid/pubid#706 §4 + §8): the
# module-composition port of cen_cenelec. This harness measures the
# boundary of what the v1 module library absorbs, and gates it:
#
#   * every corpus row the composed grammar parses must agree
#     byte-for-byte with the coded flavor on the identity surfaces
#     (to_s, to_hash) — a parsed row that drifts is a defect in the
#     definition or the compiler, never a fixture edit;
#   * every row OUTSIDE the composition's surface must fail to parse —
#     the compiled flavor must not accept what its model cannot
#     represent;
#   * the LEDGER below pins the per-file row totals (the corpus files'
#     conservation) and the absorbed floor, so a compiler advance that
#     starts absorbing former-gap rows turns this spec red and forces a
#     conscious ledger update.
#
# The unabsorbed rows are the measured tier evidence for the cen_cenelec
# tier-B assignment: the machinery the modules do NOT absorb is coded
# (the six blockers are documented in definitions/cen.pfs's header).

require "spec_helper"
require "pubid/conformance"

RSpec.describe "Pubid::CenPfs — the module-composition boundary, measured" do
  corpus_repo = ENV.fetch("PUBID_TESTSUITE_PATH",
                          File.expand_path("../../../../pubid-testsuite", __dir__))
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

  # rows grouped per payload file: [test_case, absorbed?]
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

  # Per-row gates: parity where absorbed, rejection where not.
  measured.each do |fname, groups|
    groups[:absorbed].each do |test_case|
      input = test_case.representations.human

      it "[#{fname}] #{test_case.id} (#{input.inspect}) agrees byte-for-byte with the coded flavor" do
        coded = Pubid::CenCenelec.parse(input)
        pfs = Pubid::CenPfs.parse(input)

        expect(pfs.class).not_to eq(coded.class)
        expect(pfs.to_s).to eq(coded.to_s)
        expect(pfs.to_hash).to eq(coded.to_hash)
      end

      it "[#{fname}] #{test_case.id} round-trips through its own from_hash" do
        pfs = Pubid::CenPfs.parse(input)
        expect(Pubid::CenPfs::Identifier.from_hash(pfs.to_hash)).to eq(pfs)
      end
    end

    groups[:unabsorbed].each do |test_case|
      input = test_case.representations.human
      it "[#{fname}] #{test_case.id} (#{input.inspect}) stays outside the composition's surface" do
        # the compiled flavor must not accept what its model cannot
        # represent — accepting without representing is the silent
        # failure this harness exists to prevent
        expect { Pubid::CenPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  # The ledger: the measured boundary, pinned per payload file. The six
  # coded-machinery blockers the counts stand for are documented in
  # definitions/cen.pfs (pubid-grammar): multi-type emission, the draft
  # stage machinery, the wrapper identity synthesis, the adopted-base
  # delegation, the publisher-type rules, the official URN composition.
  LEDGER = {
    "adopted_european_norm" => 17,      # blockers 4 (EN ISO/IEC delegation), 6 — all 17 unabsorbed
    "amendment" => 15,                  # blocker 3 (supplement wrapper synthesis) — all 15 unabsorbed
    "cen_report" => 22,                 # blockers 1 (multi-type), 5 (publisher types) — all 22 unabsorbed
    "cen_workshop_agreement" => 1,      # blockers 1, 5 — unabsorbed
    "consolidated_identifier" => 18,    # blocker 3 (the "+" bundle machinery) — all 18 unabsorbed
    "corrigendum" => 14,                # blocker 3 — all 14 unabsorbed
    "european_norm" => 67,              # 55 absorbed byte-identically; 12 unabsorbed (blockers 2 prEN/FprEN stages, 3, 4)
    "european_prestandard" => 7,        # blockers 1, 4 (the ENV switch) — all 7 unabsorbed
    "european_specification" => 2,      # blockers 1, 5 — unabsorbed
    "fragment" => 1,                    # blocker 3 — unabsorbed
    "guide" => 11,                      # blockers 1, 5 — all 11 unabsorbed
    "harmonization_document" => 3,      # blockers 1, 5 — unabsorbed
    "technical_report" => 7,            # blockers 1, 5 — all 7 unabsorbed
    "technical_specification" => 4,     # blockers 1, 5 — unabsorbed
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

  it "absorbs the EN face byte-identically (the modules' proof)" do
    absorbed_total = measured.values.sum { |g| g[:absorbed].size }
    expect(absorbed_total).to eq(55)
    # zero absorbed rows drift — that is the per-row gates above; this
    # assertion is the floor the modules must never fall under
    expect(absorbed_total).to be_positive
  end

  it "never hijacks Pubid.parse — the coded flavor keeps routing CEN" do
    expect(Pubid.parse("EN 12464-1:2011")).to be_a(Pubid::CenCenelec::Identifier)
  end

  it "registers beside the coded flavor (coexistence, not cutover)" do
    expect(Pubid::Registry.registered?(:cen_cenelec)).to be(true)
    expect(Pubid::Registry.registered?(:cen_pfs)).to be(true)
  end
end
