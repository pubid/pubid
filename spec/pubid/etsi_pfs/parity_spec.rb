# frozen_string_literal: true

# The etsi parity gate (pubid/pubid#706 phase 2 + phase 3): the
# PFS-compiled `etsi_pfs` flavor versus the coded `Pubid::Etsi` over the
# FULL fixture inventory (24,718 pass fixtures — the largest corpus a
# compiled flavor has been bracketed against) plus constructed edge
# cases. Drift is a defect in the DEFINITION (pubid-grammar's
# definitions/etsi.pfs) or the compiler — never a reason to relax an
# expectation here.
#
# Measured parity, per surface (2026-11, parsanol 1.3.126, compiler v2):
#
#   accept        24,718 / 24,718  (100% — the language bracket)
#   negatives     same Pubid::Errors::ParseError on both sides
#   to_hash       24,718 / 24,718  (FULL parity — phase 3 closed all
#                 three constructs: collection bindings (`parts` binds
#                 its item per repetition), the ed.N face (the fold
#                 onto version + is_edition), and the supplement
#                 wrappers (the synthesized Amendment/Corrigendum
#                 classes over the base standard))
#   to_pubid_urn  24,718 / 24,718  (purn parity is a function of hash
#                 parity: the alias's hash carries the scheme's
#                 canonical _type, so it encodes through the coded
#                 schema)
#   to_s          the full printed face — the canonical template's
#                 presence-guarded optionals and the V/ed alternated
#                 tail render what the input carried
#   to_urn        the ordered segments the definition's urn.official
#                 declares (type lowercased, the composed code, the
#                 v/ed version face, the year-month date group) —
#                 byte-identical with the coded generator on every row
#                 where the coded one renders at all; the coded
#                 generator's month-08/09 ArgumentError is a pre-existing
#                 defect the compiled generator does not share
#   to_mr_string  the `mr:` hooks (type / number / year / edition) over
#                 the columns, plus the wrapper's supplement suffix —
#                 byte-identical with the coded hooks

require "pubid"

INVENTORY = File.readlines(File.expand_path(
  "../../fixtures/etsi/identifiers/full/technical_specification.txt",
  __dir__,
)).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }.freeze

# Bare, partial and dated references — bare ids render as the core face,
# dated ids carry their tails.
PARITY_INPUTS = [
  "ETSI EN 300 175",            # bare
  "ETSI TS 103 702",            # bare
  "ETSI GTS GSM 02.01",         # bare, GSM number shape
  "ETSI EG 200 053",            # bare
  "ETSI EG 201 880 V1.2.1",     # version, no date
  "ETSI EG 200 053 V1.5.1",     # version, no date
  "ETSI EG 200 053 (2004-06)",  # date, no version
  "ETSI EG 200 053 V1.5.1 (2004-06)", # full
  "ETSI GTS GSM 02.01 V5.5.0 (1999-08)",
  "ETSI GR NFV-EVE 008 V3.1.1 (2017-12)",
  "ETSI I-ETS 300 003 V1.1.1 (1991-08)",
].freeze

# The coded fixtures' rejects plus near-miss shapes around every
# optional: all 23 verified against the coded flavor first (both flavors
# reject each one; the two near-misses both flavors accept — "V1..1"
# carries dots inside version_char, and "GS" is a real type token — are
# PARITY-NEGATIVE omissions, not entries).
PARITY_NEGATIVES = [
  "nonsense",
  "ETSI",
  "ETSI EN",
  "ETSI XX 100",                        # unknown type token
  "ETSI EN 300 175 V",                  # empty version
  "ETSI EN 300 175 V1.2.x",             # bad version char
  "ETSI EN 300 175 (",                  # dangling date opener
  "ETSI EN 300 175 (2004-6)",           # month must be 2 digits
  "ETSI EN 300 175 V1.2.3 extra",       # trailing junk
  "ETSI EN 300 175 (2004)",             # year without month
  "ETSI EN 300 175 (04-06)",            # year must be 4 digits
  "ETSI EN 300 175-1- V1.1.1 (2000-01)", # dangling part dash
  "ETSI EN 300 175/A1X",                # bad supplement spelling
  "ETSI EN 300 175/1",                  # supplement without kind
  "ETSI EN 300 175 edX",                # bad edition
  "ETSI EN 300 175 ed.1.2",             # edition carries dots
  "ETSI EN 300 175 v1.1.1",             # lowercase V
  "ETSI IETS 300 003",                  # missing I-ETS dash
  "ETSI EN300 175",                     # missing separator
  "etsi EN 300 175",                    # lowercase publisher
  "ETSI EN 300 175 V1.1.1 (20000-01)",  # 5-digit year
  "ETSI EN 300 175 (2004-06",           # unclosed date
  "ETSI TS 100 100 V",                  # dangling V tail
].freeze

RSpec.describe "Pubid::EtsiPfs parity with the coded Pubid::Etsi" do
  describe "the language bracket (accept surface)" do
    it "parses every one of the #{INVENTORY.size} inventory inputs the coded flavor parses" do
      expect(INVENTORY.size).to eq(24_718)

      INVENTORY.each do |input|
        coded = Pubid::Etsi.parse(input)
        compiled = Pubid::EtsiPfs.parse(input)
        expect(compiled).to be_a(Pubid::Identifier)
        # The bound captures are the coded model's columns. A supplement
        # row's own `number` is its Integer ordinal, so the flat columns
        # are compared on the base standard rows only.
        unless coded.is_a?(Pubid::Etsi::Identifiers::SupplementIdentifier)
          expect(compiled.type).to eq(coded.type)
          expect(compiled.number).to eq(coded.number)
        end
      end
    end

    it "rejects every negative with the same ParseError as the coded flavor" do
      PARITY_NEGATIVES.each do |input|
        expect { Pubid::Etsi.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
        expect { Pubid::EtsiPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  describe "byte parity on every surface" do
    it "agrees on to_hash and to_pubid_urn for every one of the #{INVENTORY.size} inventory rows" do
      parity = 0

      INVENTORY.each do |input|
        coded = Pubid::Etsi.parse(input)
        compiled = Pubid::EtsiPfs.parse(input)
        expect(compiled.to_hash).to eq(coded.to_hash)
        expect(compiled.to_pubid_urn).to eq(coded.to_pubid_urn)
        # The alias's own round trip rides the same pass.
        expect(Pubid::EtsiPfs::Identifier.from_hash(compiled.to_hash)).to eq(compiled)
        parity += 1
      end

      expect(parity).to eq(24_718)
    end

    it "agrees on to_s for every one of the #{INVENTORY.size} inventory rows " \
       "(the conditional render segments render the printed form)" do
      INVENTORY.each do |input|
        expect(Pubid::EtsiPfs.parse(input).to_s)
          .to eq(Pubid::Etsi.parse(input).to_s)
      end
    end

    it "agrees on to_mr_string for every one of the #{INVENTORY.size} inventory rows " \
       "(the mr: hooks over the columns)" do
      INVENTORY.each do |input|
        expect(Pubid::EtsiPfs.parse(input).to_mr_string)
          .to eq(Pubid::Etsi.parse(input).to_mr_string)
      end
    end

    PARITY_INPUTS.each do |input|
      it "agrees byte-for-byte with the coded flavor on #{input.inspect}" do
        coded = Pubid::Etsi.parse(input)
        compiled = Pubid::EtsiPfs.parse(input)

        expect(compiled.class).to be < Pubid::Identifier
        expect(compiled.class).not_to eq(coded.class)
        expect(compiled.to_hash).to eq(coded.to_hash)
        expect(compiled.to_pubid_urn).to eq(coded.to_pubid_urn)
      end

      it "round-trips #{input.inspect} through its own from_hash" do
        compiled = Pubid::EtsiPfs.parse(input)
        expect(Pubid::EtsiPfs::Identifier.from_hash(compiled.to_hash)).to eq(compiled)
      end
    end
  end

  describe "the former gaps, now features (phase 3)" do
    it "collection bindings: a parts row carries the coded array, dropped when bare" do
      coded = Pubid::Etsi.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)")
      compiled = Pubid::EtsiPfs.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)")

      expect(compiled.to_hash["parts"]).to eq(%w[1 0])
      expect(compiled.to_hash).to eq(coded.to_hash)
      expect(Pubid::EtsiPfs.parse("ETSI EN 300 175").to_hash).not_to include("parts")
    end

    it "the edition face: an ed.N row folds onto version + is_edition" do
      coded = Pubid::Etsi.parse("ETSI I-ETS 300 003 ed.1 (1991-08)")
      compiled = Pubid::EtsiPfs.parse("ETSI I-ETS 300 003 ed.1 (1991-08)")

      expect(compiled.to_hash["version"]).to eq("1")
      expect(compiled.to_hash["is_edition"]).to be(true)
      expect(compiled.to_hash).not_to include("edition")
      expect(compiled.to_hash).to eq(coded.to_hash)
      # a V row carries the bare version, no flag
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_hash)
        .not_to include("is_edition")
    end

    it "supplement wrappers: a /A//C run folds into the synthesized wrapper chain" do
      coded = Pubid::Etsi.parse("ETSI ETR 108/A1 ed.1 (1995-08)")
      compiled = Pubid::EtsiPfs.parse("ETSI ETR 108/A1 ed.1 (1995-08)")

      expect(compiled).to be_a(Pubid::EtsiPfs::Identifiers::Amendment)
      expect(compiled.number).to eq(1)
      expect(compiled.base).to be_a(Pubid::EtsiPfs::Identifiers::Standard)
      expect(compiled.base.type).to eq("ETR")
      expect(compiled.to_hash).to eq(coded.to_hash)
      expect(compiled.to_hash["_type"]).to eq("pubid:etsi:amendment")

      chained = Pubid::Etsi.parse("ETSI ETS 300 092-1/A1/C1 ed.1 (1994-04)")
      compiled_chain = Pubid::EtsiPfs.parse("ETSI ETS 300 092-1/A1/C1 ed.1 (1994-04)")
      # the printed run's order IS the nesting: C1 over A1 over the standard
      expect(compiled_chain).to be_a(Pubid::EtsiPfs::Identifiers::Corrigendum)
      expect(compiled_chain.base).to be_a(Pubid::EtsiPfs::Identifiers::Amendment)
      expect(compiled_chain.base.base).to be_a(Pubid::EtsiPfs::Identifiers::Standard)
      expect(compiled_chain.to_hash).to eq(chained.to_hash)
    end

    it "conditional render segments: the printed tail renders what the input carried" do
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_s)
        .to eq("ETSI EG 200 053 V1.5.1 (2004-06)")
      expect(Pubid::EtsiPfs.parse("ETSI I-ETS 300 003 ed.1 (1991-08)").to_s)
        .to eq("ETSI I-ETS 300 003 ed.1 (1991-08)")
      expect(Pubid::EtsiPfs.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)").to_s)
        .to eq("ETSI EN 300 019-1-0 V2.1.2 (2003-09)")
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 053").to_s)
        .to eq("ETSI EG 200 053")
    end

    it "the official URN segments: the declared composition is byte-identical " \
       "with the coded generator where the coded one renders at all" do
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_urn)
        .to eq("urn:etsi:eg:200 053:v1.5.1:2004-06")
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 053").to_urn)
        .to eq("urn:etsi:eg:200 053")
      expect(Pubid::EtsiPfs.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)").to_urn)
        .to eq("urn:etsi:en:300 019-1-0:v2.1.2:2003-09")

      # The coded flavor's pre-existing defect: format('%02d', month) on
      # the zero-padded string raises for 08 and 09. The compiled
      # generator renders the captured month verbatim — the same URN the
      # coded one produces for every other month, and no raise here.
      expect { Pubid::Etsi.parse("ETSI EG 200 351 V2.2.2 (1998-09)").to_urn }
        .to raise_error(ArgumentError)
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 351 V2.2.2 (1998-09)").to_urn)
        .to eq("urn:etsi:eg:200 351:v2.2.2:1998-09")
    end

    it "MR slug hooks: the declared segments compose the coded slug byte-for-byte" do
      expect(Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_mr_string)
        .to eq("etsi.eg.200-053.2004-06.1-5-1")
      expect(Pubid::EtsiPfs.parse("ETSI I-ETS 300 003 ed.1 (1991-08)").to_mr_string)
        .to eq("etsi.i-ets.300-003.1991-08.1")
      expect(Pubid::EtsiPfs.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)").to_mr_string)
        .to eq("etsi.en.300-019-1-0.2003-09.2-1-2")
      expect(Pubid::EtsiPfs.parse("ETSI ETR 108/A1 ed.1 (1995-08)").to_mr_string)
        .to eq("etsi.etr.108.1995-08.1_a1.1")
    end
  end

  it "shares the input guards with the coded flavor" do
    [Pubid::Etsi, Pubid::EtsiPfs].each do |flavor|
      expect { flavor.parse(42) }
        .to raise_error(Pubid::Errors::InvalidInputError, Pubid::INPUT_NOT_A_STRING_MESSAGE)
      expect { flavor.parse("x" * (Pubid::MAX_INPUT_LENGTH + 1)) }
        .to raise_error(Pubid::Errors::InvalidInputError,
                        Pubid::INPUT_TOO_LONG_MESSAGE)
    end
  end

  it "never hijacks Pubid.parse — the coded flavor keeps routing ETSI" do
    expect(Pubid.parse("ETSI EG 200 053 V1.5.1 (2004-06)"))
      .to be_a(Pubid::Etsi::Identifiers::EtsiStandard)
  end

  it "registers beside the coded flavor (coexistence, not cutover)" do
    expect(Pubid::Registry.registered?(:etsi)).to be(true)
    expect(Pubid::Registry.registered?(:etsi_pfs)).to be(true)
    # The dev alias declares the scheme-canonical namespace, so its URN
    # generator pins the etsi namespace while its schema registers under
    # its own key.
    expect(Pubid::EtsiPfs::UrnGenerator.new(nil).urn_namespace).to eq("etsi")
    expect(Pubid::PubidUrn.flavor_schema("etsi_pfs")).not_to be_nil
    expect(Pubid::PubidUrn.flavor_schema("etsi")).not_to be_nil
  end
end
