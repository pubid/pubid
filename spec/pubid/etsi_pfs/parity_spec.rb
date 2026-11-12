# frozen_string_literal: true

# The etsi parity gate (pubid/pubid#706 phase 2): the PFS-compiled
# `etsi_pfs` flavor versus the coded `Pubid::Etsi` over the FULL fixture
# inventory (24,718 pass fixtures — the largest corpus a compiled flavor
# has been bracketed against) plus constructed edge cases. Drift is a
# defect in the DEFINITION (pubid-grammar's definitions/etsi.pfs) or the
# compiler — never a reason to relax an expectation here.
#
# Measured parity, per surface (2026-11, parsanol 1.3.126):
#
#   accept        24,718 / 24,718  (100% — the language bracket)
#   negatives     same Pubid::Errors::ParseError on both sides
#   to_hash       18,945 / 24,718  (exactly the rows whose identity
#                 carries none of: collection parts, the ed.N edition
#                 face, a supplement wrapper — the three constructs
#                 pfs:1 cannot declare; see the bucket examples below)
#   to_pubid_urn  18,945 / 24,718  (the same rows — purn parity is a
#                 function of hash parity: the alias's hash carries the
#                 scheme's canonical _type, so it encodes through the
#                 coded schema)
#   to_s          the canonical CORE face only — pfs:1 render faces
#                 cannot render optionals, so every corpus row (all of
#                 which carry version/ed + date) renders shorter;
#                 bare and partial ids agree byte-for-byte
#   to_urn        the coded generator is hand-written Ruby
#                 (urn:etsi:{type}:{code}:{version}:{date}); the
#                 generated generator pins the namespace only
#   to_mr_string  the coded slug reads the flavor's mr_* hooks
#                 (type/parts/edition/date segments); the base hooks
#                 find none of them on the compiled columns
#
# The bucket examples pin each divergence to its construct, so compiler
# progress (collection bindings, the edition face, supplement wrappers,
# render tails, URN/MR declaration surface) turns them red — the signal
# to move the row into the parity examples above.

require "pubid"

INVENTORY = File.readlines(File.expand_path(
  "../../fixtures/etsi/identifiers/full/technical_specification.txt",
  __dir__,
)).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }.freeze

# Bare and partial references — the identities pfs:1 CAN represent in
# full: no parts run, no ed.N face, no supplement wrapper. Bare ids
# agree on to_s too; partial ids agree on to_hash and to_pubid_urn.
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
  # Which coded construct a row carries. The buckets are the three
  # pfs:1 compiler gaps plus the representable rest.
  def bucket_of(coded)
    hash = coded.to_hash
    return :supplement if hash.key?("base")
    return :edition if hash.key?("is_edition")
    return :parts if hash.key?("parts")

    :plain
  end

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

  describe "byte parity on the surfaces pfs:1 can represent" do
    it "agrees on to_hash and to_pubid_urn for every inventory row in the plain bucket" do
      parity = 0

      INVENTORY.each do |input|
        coded = Pubid::Etsi.parse(input)
        next unless bucket_of(coded) == :plain

        compiled = Pubid::EtsiPfs.parse(input)
        expect(compiled.to_hash).to eq(coded.to_hash)
        expect(compiled.to_pubid_urn).to eq(coded.to_pubid_urn)
        # The alias's own round trip rides the same pass.
        expect(Pubid::EtsiPfs::Identifier.from_hash(compiled.to_hash)).to eq(compiled)
        parity += 1
      end

      # The inventory's bucket split, pinned so a corpus change that
      # moves a row across buckets is visible.
      expect(parity).to eq(18_945)
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

    it "renders every PARITY_INPUT as the coded flavor's to_s" do
      # to_s parity is the bare sub-set: a row with version or date
      # renders the tail in the coded flavor, which the canonical core
      # face cannot (the render-face gap).
      ["ETSI EN 300 175", "ETSI TS 103 702", "ETSI GTS GSM 02.01",
       "ETSI EG 200 053"].each do |input|
        expect(Pubid::EtsiPfs.parse(input).to_s).to eq(Pubid::Etsi.parse(input).to_s)
      end
    end
  end

  describe "the compiler gaps, pinned per construct" do
    it "collection bindings (gap): a parts row carries the printed dash run, " \
       "not the coded array" do
      coded = Pubid::Etsi.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)")
      compiled = Pubid::EtsiPfs.parse("ETSI EN 300 019-1-0 V2.1.2 (2003-09)")

      expect(coded.to_hash["parts"]).to eq(%w[1 0])
      expect(compiled.to_hash["parts"]).to eq("-1-0")
    end

    it "the edition face (gap): an ed.N row carries `edition`, not the " \
       "coded `version` + `is_edition` pair" do
      coded = Pubid::Etsi.parse("ETSI I-ETS 300 003 ed.1 (1991-08)")
      compiled = Pubid::EtsiPfs.parse("ETSI I-ETS 300 003 ed.1 (1991-08)")

      expect(coded.to_hash["version"]).to eq("1")
      expect(coded.to_hash["is_edition"]).to be(true)
      expect(compiled.to_hash["edition"]).to eq("1")
      expect(compiled.to_hash).not_to include("version", "is_edition")
    end

    it "supplement wrappers (gap): a /A//C row stays a flat etsi-standard " \
       "row carrying the printed run" do
      coded = Pubid::Etsi.parse("ETSI ETR 108/A1 ed.1 (1995-08)")
      compiled = Pubid::EtsiPfs.parse("ETSI ETR 108/A1 ed.1 (1995-08)")

      expect(coded.to_hash["_type"]).to eq("pubid:etsi:amendment")
      expect(coded.to_hash["number"]).to eq(1)
      expect(compiled.to_hash["_type"]).to eq("pubid:etsi:etsi-standard")
      expect(compiled.to_hash["supplements"]).to eq("/A1")
    end

    it "render tails (gap): the canonical face renders the core only, so " \
       "a dated row renders shorter than the coded flavor" do
      compiled = Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)")

      expect(compiled.to_s).to eq("ETSI EG 200 053")
      expect(Pubid::Etsi.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_s)
        .to eq("ETSI EG 200 053 V1.5.1 (2004-06)")
    end

    it "official URN (gap): the compiled to_urn pins the namespace only — " \
       "and the coded generator itself raises on months 08/09 (pre-existing)" do
      compiled = Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)")

      expect(compiled.to_urn).to eq("urn:etsi:200 053:2004")
      expect(Pubid::Etsi.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_urn)
        .to eq("urn:etsi:eg:200 053:v1.5.1:2004-06")
      # The coded flavor's pre-existing defect: format('%02d', month)
      # on the zero-padded string raises for 08 and 09.
      expect { Pubid::Etsi.parse("ETSI EG 200 351 V2.2.2 (1998-09)").to_urn }
        .to raise_error(ArgumentError)
      expect { Pubid::EtsiPfs.parse("ETSI EG 200 351 V2.2.2 (1998-09)").to_urn }
        .not_to raise_error
    end

    it "MR slug (gap): the compiled slug carries the bare number segment — " \
       "the coded mr_* hooks (type/parts/edition/date) are not declarable" do
      compiled = Pubid::EtsiPfs.parse("ETSI EG 200 053 V1.5.1 (2004-06)")

      expect(compiled.to_mr_string).to eq("200 053")
      expect(Pubid::Etsi.parse("ETSI EG 200 053 V1.5.1 (2004-06)").to_mr_string)
        .to eq("etsi.eg.200-053.2004-06.1-5-1")
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
