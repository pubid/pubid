# frozen_string_literal: true

# The bsi_pfs parity gate (pubid/pubid#706 §4): the PFS-compiled
# module-composition flavor `bsi_pfs` versus the coded `Pubid::Bsi` over
# the FULL bsi corpus (1,500 payload rows, every payload file). This is
# the FIRST module-composition proof flavor — the composition is the
# module library (national.prefix + en.overlay over the iso/iec inners),
# and the measurement is the honest boundary of what that composition
# absorbs today. Drift is a defect in the DEFINITION
# (pubid-grammar's definitions/bsi.pfs) or the compiler — never a reason
# to relax an expectation here.
#
# MEASURED LEDGER (2026-11, parsanol 1.5.1.0, grammar origin/main with
# the bsi-absorption compiler features — the adopted attribute-name
# parameterization (`adopted.attribute: base`), the root-through
# identity, the typed-trio designation surface (type/stage/typed_stage
# with harmonized_stages), the glued adopted edition face, the
# marker-less consolidated bundle and the nested publisher wire shape —
# and the pfs-compiler-v2 face-only designation (`designation: face`,
# issue #151) that composes the standalone-AMD family:
#
#   absorbed    847 / 1,500 — byte parity on every identity surface
#               (class, to_s, to_hash, to_urn, to_pubid_urn,
#               to_mr_string) plus from_hash round-trip: the plain BS
#               face (304), the adoption wrappers with the uniform
#               `base` slot, the root-through URN/MR reads and the
#               nested publisher (aen 267 including the "BS HD IEC
#               60364-8-81 ED1" glued-ED face, ais 74), the typed trio
#               (PAS 56 / PD 74 / DD 13 / TS 3) with the full
#               type/stage/typed_stage serialization and the
#               ":stage.published" URN segment, the marker-less
#               consolidated bundles (52 — the members carry the
#               bundle's base, the URN appends the members' chains
#               directly, the MR slug is the base document's own), and
#               the face-only standalone amendments (4 — "AMD 11015" is
#               {_type, number}: the head token prints and selects the
#               class while the column keeps the organization default).
#   classified  0 — the #737 ledger's wrapper-emission (393) and
#               typed-trio (146) families closed: every divergence the
#               measured boundary recorded flipped to byte parity.
#   unabsorbed  653 — rows outside the composition surface, rejected
#               (ParseError, never a wrong class): the thirty-plus coded
#               families the module library does not model (aerospace,
#               Flex, committee documents, index/method/section/test
#               suffixes, addenda/supplements, national annexes, Expert
#               commentary, bundles, sets, value-added wrappers, DISC
#               escalation prefix) and four declared shapes (the AMD
#               keyword supplement spelling, the second_number slash
#               column, the CISPR aerospace routing, the "(Book)" /
#               "(R2004)" parenthetical suffixes). Every family's
#               fail-closed reason is recorded in pubid-grammar's
#               definitions/bsi.pfs header (the issue-#151 tier-B/C
#               ledger).
#
# A row the compiled flavor does NOT absorb fails nothing here — it sits
# in the ledger below, pinned per payload file, so a corpus addition or
# a regression turns red and forces a conscious ledger update. An
# absorbed row losing parity, a classified row changing its divergence
# signature, or an unabsorbed row starting to parse all fail this spec.

require "spec_helper"
require "pubid/conformance"

RSpec.describe "Pubid::BsiPfs parity with the coded Pubid::Bsi" do
  corpus_repo = ENV.fetch("PUBID_TESTSUITE_PATH",
                          File.expand_path("../../../../pubid-testsuite",
                                           __dir__))
  corpus_dir = File.join(corpus_repo, "tests")
  corpus_present = File.directory?(File.join(corpus_dir, "bsi"))
  before do
    skip "pubid-testsuite corpus absent" unless corpus_present
    Pubid.eager_load_flavors!
  end

  files = if corpus_present
            Dir[File.join(corpus_dir, "bsi", "*.yaml")]
              .reject { |p| File.basename(p).start_with?("_") }.sort
          else
            []
          end

  # The surfaces the coded flavor exposes and the compiled one must
  # match (or consciously diverge, per the ledger).
  BSI_PFS_SURFACES = %i[to_s to_hash to_urn to_pubid_urn to_mr_string].freeze

  safe_call = lambda do |id, meth|
    id.public_send(meth)
  rescue StandardError
    "RAISE:#{::Pubid::Errors::InvalidInputError}"
  end

  # rows grouped per payload file: absorbed / classified (signature →
  # rows) / unabsorbed — the signature names the surfaces that diverge,
  # so a regression that CHANGES a divergence reports WHERE.
  measured = Hash.new do |h, k|
    h[k] = { absorbed: [], classified: Hash.new { |hh, kk| hh[kk] = [] },
             unabsorbed: [], coded_error: [] }
  end
  files.each do |path|
    fname = File.basename(path, ".yaml")
    Pubid::Conformance::Corpus.load_file(path).each do |test_case|
      next if test_case.review? || test_case.quarantined? || test_case.error_case?

      input = test_case.representations.human
      coded = begin
        Pubid::Bsi.parse(input)
      rescue StandardError => e
        measured[fname][:coded_error] << [test_case.id, input,
                                          e.class.name.split("::").last].freeze
        next
      end

      pfs = begin
        Pubid::BsiPfs.parse(input)
      rescue Pubid::Errors::ParseError
        measured[fname][:unabsorbed] << [test_case.id, input].freeze
        next
      rescue StandardError => e
        measured[fname][:unabsorbed] << [test_case.id, input,
                                         "NON-PARSE-ERROR:#{e.class.name.split('::').last}"].freeze
        next
      end

      diffs = BSI_PFS_SURFACES.filter_map do |m|
        safe_call.call(pfs, m) == safe_call.call(coded, m) ? nil : m
      end
      class_diverged = pfs.class.name.split("::").last !=
                       coded.class.name.split("::").last

      if diffs.empty? && !class_diverged
        measured[fname][:absorbed] << test_case
      else
        signature = ([class_diverged ? "class" : nil] + diffs).compact.join("+")
        measured[fname][:classified][signature] << test_case
      end
    end
  end

  # Per-row gates: byte parity on every surface where absorbed; the
  # pinned divergence signature where classified; rejection where
  # unabsorbed.
  measured.each do |fname, groups|
    groups[:absorbed].each do |test_case|
      input = test_case.representations.human

      it "[#{fname}] #{test_case.id} (#{input.inspect}) agrees byte-for-byte " \
         "with the coded flavor on every identity surface" do
        coded = Pubid::Bsi.parse(input)
        pfs = Pubid::BsiPfs.parse(input)

        expect(pfs.class).not_to eq(coded.class)
        expect(pfs.class.name.split("::").last)
          .to eq(coded.class.name.split("::").last)
        expect(pfs.to_s).to eq(coded.to_s)
        expect(pfs.to_hash).to eq(coded.to_hash)
        expect(pfs.to_urn).to eq(coded.to_urn)
        expect(pfs.to_pubid_urn).to eq(coded.to_pubid_urn)
        # through the measurement's own lens: a surface that RAISES is
        # part of the identity contract too (the coded BSI mr_edition
        # raises on the wrappers' String edition — pinned behavior), so
        # parity means the same value OR the same raise on both sides
        expect(safe_call.call(pfs, :to_mr_string))
          .to eq(safe_call.call(coded, :to_mr_string))
      end

      it "[#{fname}] #{test_case.id} round-trips through its own from_hash" do
        pfs = Pubid::BsiPfs.parse(input)
        expect(Pubid::BsiPfs::Identifier.from_hash(pfs.to_hash)).to eq(pfs)
      end
    end

    groups[:classified].each do |signature, rows|
      rows.each do |test_case|
        input = test_case.representations.human
        prints_input = !signature.split("+").include?("to_s")

        it "[#{fname}] #{test_case.id} (#{input.inspect}) parses with the " \
           "printed face and the pinned #{signature.inspect} divergence" do
          coded = Pubid::Bsi.parse(input)
          pfs = Pubid::BsiPfs.parse(input)

          expect(pfs.class.name.split("::").last)
            .to eq(coded.class.name.split("::").last)
          expect(pfs.to_s).to eq(coded.to_s) if prints_input
          actual = BSI_PFS_SURFACES.filter_map do |m|
            safe_call.call(pfs, m) == safe_call.call(coded, m) ? nil : m
          end
          expect(actual.join("+")).to eq(signature)
        end
      end
    end

    groups[:unabsorbed].each do |row|
      input = row[1]
      wrong_class = row[2].to_s.start_with?("NON-PARSE-ERROR")

      it "[#{fname}] #{row[0]} (#{input.inspect}) stays outside the declared " \
         "surface" do
        # the compiled flavor must not accept what its model cannot
        # represent — accepting without representing is the silent
        # failure this harness exists to prevent; the rejection is a
        # parse failure, never a wrong-class error
        expect(wrong_class).to be(false)
        expect { Pubid::BsiPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  # THE LEDGER: the measured boundary, pinned per payload file —
  # absorbed / classified (by divergence signature) / unabsorbed. A new
  # corpus row, a corpus file, or a changed divergence must enter here
  # consciously.
  BSI_PFS_LEDGER = {
    "addendum_document" => { absorbed: 0, classified: {}, unabsorbed: 22 },
    "adopted_european_norm" => { absorbed: 267, classified: {}, unabsorbed: 0 },
    "adopted_international_standard" => { absorbed: 74, classified: {}, unabsorbed: 7 },
    "aerospace_standard" => { absorbed: 0, classified: {}, unabsorbed: 339 },
    "british_standard" => { absorbed: 304, classified: {}, unabsorbed: 42 },
    "bundled_identifier" => { absorbed: 0, classified: {}, unabsorbed: 27 },
    "committee_document" => { absorbed: 0, classified: {}, unabsorbed: 6 },
    "consolidated_identifier" => { absorbed: 52, classified: {}, unabsorbed: 46 },
    "detailed_specification" => { absorbed: 0, classified: {}, unabsorbed: 16 },
    "disc" => { absorbed: 0, classified: {}, unabsorbed: 9 },
    "draft_document" => { absorbed: 13, classified: {}, unabsorbed: 0 },
    "expert_commentary" => { absorbed: 0, classified: {}, unabsorbed: 25 },
    "explanatory_supplement" => { absorbed: 0, classified: {}, unabsorbed: 1 },
    "flex" => { absorbed: 0, classified: {}, unabsorbed: 23 },
    "index" => { absorbed: 0, classified: {}, unabsorbed: 13 },
    "method" => { absorbed: 0, classified: {}, unabsorbed: 14 },
    "national_annex" => { absorbed: 0, classified: {}, unabsorbed: 18 },
    "publicly_available_specification" => { absorbed: 56, classified: {}, unabsorbed: 0 },
    "published_document" => { absorbed: 74, classified: {}, unabsorbed: 2 },
    "section" => { absorbed: 0, classified: {}, unabsorbed: 11 },
    "set" => { absorbed: 0, classified: {}, unabsorbed: 1 },
    "standalone_amendment" => { absorbed: 4, classified: {}, unabsorbed: 0 },
    "supplement_document" => { absorbed: 0, classified: {}, unabsorbed: 18 },
    "supplementary_index" => { absorbed: 0, classified: {}, unabsorbed: 1 },
    "technical_specification" => { absorbed: 3, classified: {}, unabsorbed: 0 },
    "test_method" => { absorbed: 0, classified: {}, unabsorbed: 6 },
    "value_added_publication" => { absorbed: 0, classified: {}, unabsorbed: 6 },
  }.freeze

  it "the measured absorption matches the pinned ledger" do
    actual = measured.to_h do |fname, groups|
      [fname,
       { absorbed: groups[:absorbed].size,
         classified: groups[:classified].transform_values(&:size),
         unabsorbed: groups[:unabsorbed].size }]
    end
    expect(actual).to eq(BSI_PFS_LEDGER)
    # the ledger covers every payload file: a new corpus file must enter
    # the ledger consciously, like a new row
    expect(actual.keys).to match_array(BSI_PFS_LEDGER.keys)
  end

  it "absorbs the #737 classified families in full (847 rows) at byte parity" do
    absorbed_total = measured.values.sum { |g| g[:absorbed].size }
    expect(absorbed_total).to eq(847)
    classified_total = measured.values.sum do |g|
      g[:classified].values.map(&:size).sum
    end
    expect(classified_total).to eq(0)
  end

  it "no row raises a non-parse error anywhere (the rejection contract)" do
    wrong = measured.values.flat_map { |g| g[:unabsorbed] }
                    .select { |r| r[2].to_s.start_with?("NON-PARSE-ERROR") }
    expect(wrong).to be_empty
    expect(measured.values.sum { |g| g[:coded_error].size }).to eq(0)
  end

  # The negative corpus: every ground-truth rejection stays a rejection.
  it "rejects every _negative corpus row" do
    neg = File.join(corpus_dir, "bsi", "_negative.yaml")
    rows = Array(YAML.safe_load_file(neg)).map { |r| r["input"] }
    expect(rows.size).to eq(78)
    rows.each do |input|
      expect { Pubid::BsiPfs.parse(input) }
        .to raise_error(Pubid::Errors::ParseError), input.inspect
    end
  end

  # The composition story, on real corpus shapes: the module-composition
  # faces the flavor absorbs (parse + printed face), each one of the
  # library's composition claims exercised.
  describe "the module-composition faces" do
    it "national.prefix over the plain BS face (the module's token as data)" do
      id = Pubid::BsiPfs.parse("BS 10005:1995")
      expect(id).to be_a(Pubid::BsiPfs::Identifiers::BritishStandard)
      expect(id.to_s).to eq("BS 10005:1995")
      expect(id.to_hash).to eq(Pubid::Bsi.parse("BS 10005:1995").to_hash)
      expect(id.to_urn).to eq("urn:bsi:bs:10005:1995")
      expect(id.to_mr_string).to eq("bs.10005.1995")
    end

    it "en.overlay over the cen inner: BS EN is the CEN adoption chain" do
      id = Pubid::BsiPfs.parse("BS EN 1073-2:2002")
      expect(id).to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      expect(id.to_s).to eq("BS EN 1073-2:2002")
      # the adopted document is the wrapper's uniform `base` (the identity
      # composition the modules declare), and the wrapper's identity is
      # the ROOT document's: the coded URN, MR slug and hash slot
      expect(id.base).to be_a(Pubid::CenCenelec::Identifier)
      expect(id.to_hash).to eq(Pubid::Bsi.parse("BS EN 1073-2:2002").to_hash)
      expect(id.to_urn).to eq("urn:bsi:bs:1073:-2:2002")
      expect(id.to_mr_string).to eq("bs.1073-2.2002")
      expect(id.to_pubid_urn)
        .to eq("urn:pubid:bsi:cencenelec.en:1073:part-2:year-2002:aen")
    end

    it "the multi-level chain: BS EN ISO is a BSI wrapper over a CEN " \
       "adoption over the ISO document" do
      id = Pubid::BsiPfs.parse("BS EN ISO 105-B06:2020")
      expect(id).to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      # the BSI wrapper's uniform `base`, the CEN adoption's own
      # `adopted` slot (the CEN flavor's naming — each flavor names its
      # own wrapper slot), and the ISO document under it
      expect(id.base).to be_a(Pubid::CenCenelec::Identifier)
      expect(id.base.adopted).to be_a(Pubid::Iso::Identifier)
      expect(id.to_s).to eq("BS EN ISO 105-B06:2020")
      expect(id.to_urn).to eq("urn:bsi:bs:105:-B06:2020")
    end

    it "iso.inner and iec.inner as the adopted inners (BS ISO / BS IEC)" do
      iso = Pubid::BsiPfs.parse("BS ISO 8601:2019")
      expect(iso).to be_a(Pubid::BsiPfs::Identifiers::AdoptedInternationalStandard)
      expect(iso.base).to be_a(Pubid::Iso::Identifier)
      expect(iso.to_s).to eq("BS ISO 8601:2019")
      expect(iso.to_urn).to eq("urn:bsi:bs:8601:2019")

      iec = Pubid::BsiPfs.parse("BS IEC 60747-8:2000")
      expect(iec.base).to be_a(Pubid::Iec::Identifier)
      expect(iec.to_s).to eq("BS IEC 60747-8:2000")
    end

    it "the national head over the DD/PD designations adopting CEN documents" do
      input = "DD CEN ISO/TS 12180-1:2007"
      dd = Pubid::BsiPfs.parse(input)
      expect(dd).to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      expect(dd.base).to be_a(Pubid::CenCenelec::Identifier)
      expect(dd.to_s).to eq(input)
      # the nested publisher body form (the nested {"body" => "DD"} the
      # serialization declaration keeps) and the root-through identity
      expect(dd.to_hash).to eq(Pubid::Bsi.parse(input).to_hash)
      expect(dd.to_urn).to eq("urn:bsi:dd:12180:-1:2007")
    end

    it "the IEC-internal runs stay inside the delegated adoption" do
      frag = Pubid::BsiPfs.parse("BS EN IEC 60601-1/FRAG1")
      expect(frag.to_s).to eq("BS EN IEC 60601-1/FRAG1")
      expect(frag.base.adopted).to be_a(Pubid::Iec::Identifier)

      amd_frag = Pubid::BsiPfs.parse("BS EN IEC 61535/AMD1/FRAG1")
      expect(amd_frag.to_s).to eq("BS EN IEC 61535/AMD1/FRAG1")
    end

    it "supplements.core: the plus-separated amendment run is a " \
       "consolidated bundle over the composition" do
      plain = Pubid::BsiPfs.parse("BS 10125:2014+A1:2016")
      expect(plain).to be_a(Pubid::BsiPfs::Identifiers::ConsolidatedIdentifier)
      expect(plain.identifiers.first)
        .to be_a(Pubid::BsiPfs::Identifiers::BritishStandard)
      expect(plain.identifiers.last).to be_a(Pubid::BsiPfs::Identifiers::Amendment)
      expect(plain.to_s).to eq("BS 10125:2014+A1:2016")
      # the marker-less bundle (the coded-BSI shape): the members carry
      # the bundle's base, the URN appends the member chains directly,
      # and the MR slug is the base document's own
      expect(plain.identifiers.last.base).to eq(plain.identifiers.first)
      expect(plain.to_urn).to eq("urn:bsi:bs:10125:2014:amd:1:2016")
      expect(plain.to_mr_string).to eq("bs.10125.2014")
      expect(plain.to_pubid_urn)
        .to eq("urn:pubid:bsi:consol:ids-(bsi:bs:10125:year-2014)," \
               "(bsi:bs:10125:year-2014:amd:1:year-2016)")

      adopted = Pubid::BsiPfs.parse("BS EN 1005-1:2001+A1:2008")
      expect(adopted).to be_a(Pubid::BsiPfs::Identifiers::ConsolidatedIdentifier)
      expect(adopted.identifiers.first)
        .to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      expect(adopted.to_s).to eq("BS EN 1005-1:2001+A1:2008")
      expect(adopted.to_urn).to eq("urn:bsi:bs:1005:-1:2001:amd:1:2008")
    end

    it "the marker-less bundle's to_hash is byte-identical with the coded " \
       "flavor's" do
      plain = Pubid::BsiPfs.parse("BS 10125:2014+A1:2016")
      expect(plain.to_hash).to eq(Pubid::Bsi.parse("BS 10125:2014+A1:2016").to_hash)
    end

    it "the typed trio carries the declared stage registry row " \
       "(type/stage/typed_stage, harmonized stages included)" do
      pas = Pubid::BsiPfs.parse("PAS 003:1994")
      expect(pas.to_hash).to eq(Pubid::Bsi.parse("PAS 003:1994").to_hash)
      expect(pas.typed_stage.code).to eq("pubpas")
      expect(pas.typed_stage.harmonized_stages).to eq(%w[60.00 60.60])
      # the coded URN's type abbr and stage segments (a stage_code String
      # is never the :published Symbol — the coded generator's own
      # comparison, reproduced byte-for-byte)
      expect(pas.to_urn).to eq("urn:bsi:bs:003:1994:pas:stage.published")
      expect(pas.to_mr_string).to eq("bs.pas.003.1994")

      pd = Pubid::BsiPfs.parse("PD 5730")
      expect(pd.to_hash).to eq(Pubid::Bsi.parse("PD 5730").to_hash)
      expect(pd.to_urn).to eq("urn:bsi:bs:5730:pd:stage.published")
      expect(pd.to_mr_string).to eq("bs.pd.5730")
    end

    it "the face-only standalone amendment composes (issue #151): the head " \
       "token prints and selects the class, nothing serializes beyond _type" do
      id = Pubid::BsiPfs.parse("AMD 11015")
      expect(id).to be_a(Pubid::BsiPfs::Identifiers::StandaloneAmendment)
      expect(id.to_s).to eq("AMD 11015")
      expect(id.to_hash).to eq(Pubid::Bsi.parse("AMD 11015").to_hash)
      expect(id.to_urn).to eq("urn:bsi:bs:11015")
      expect(id.to_pubid_urn).to eq("urn:pubid:bsi:sa:11015")
      expect(id.to_mr_string).to eq("bs.11015")
      expect(Pubid::BsiPfs::Identifier.from_hash(id.to_hash)).to eq(id)
    end

    it "the glued adopted edition face renders (BS HD IEC 60364-8-81 ED1)" do
      input = "BS HD IEC 60364-8-81 ED1"
      id = Pubid::BsiPfs.parse(input)
      expect(id.to_s).to eq(input)
      expect(id.edition).to eq("1")
      expect(id.to_hash).to eq(Pubid::Bsi.parse(input).to_hash)
      expect(id.to_urn).to eq("urn:bsi:bs:60364:-8:-81:v1")
      expect(id.to_pubid_urn)
        .to eq("urn:pubid:bsi:cencenelec.aen:pub-HD:adopted-" \
               "(iec:is:60364:part-8:subpart-81):aen:ed-1")
    end

    it "the publisher-type designation faces (PAS/PD/DD/TS) parse with the " \
       "printed face" do
      {
        "PAS 003:1994" => Pubid::BsiPfs::Identifiers::PubliclyAvailableSpecification,
        "PD 5730" => Pubid::BsiPfs::Identifiers::PublishedDocument,
        "DD 136-2:1986" => Pubid::BsiPfs::Identifiers::DraftDocument,
        "TS 1:1995" => Pubid::BsiPfs::Identifiers::TechnicalSpecification,
      }.each do |input, klass|
        id = Pubid::BsiPfs.parse(input)
        expect(id).to be_a(klass)
        expect(id.to_s).to eq(input)
        expect(id.to_hash["publisher"]).to be_nil # the designation IS the publisher
      end
    end

    it "the glued letter stays in the number and the part keeps its dash " \
       "in the URN" do
      glued = Pubid::BsiPfs.parse("BS 1000A:1961")
      expect(glued.number).to eq("1000A")
      expect(glued.to_hash).to eq(Pubid::Bsi.parse("BS 1000A:1961").to_hash)

      part = Pubid::BsiPfs.parse("BS 1016-107.2:1991")
      expect(part.part).to eq("107.2")
      expect(part.to_urn).to eq("urn:bsi:bs:1016:-107.2:1991")

      multi = Pubid::BsiPfs.parse("BS 5550-1.3.3:1980")
      expect(multi.part).to eq("1.3.3")
      expect(multi.to_urn).to eq("urn:bsi:bs:5550:-1.3.3:1980")
    end

    it "CISPR is refused (the coded flavor routes it to the aerospace " \
       "series, a family outside this surface)" do
      expect { Pubid::BsiPfs.parse("BS CISPR 12:1997") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "carries the resolved module composition for introspection" do
      expect(Pubid::BsiPfs::MODULES.map { |m| m[:name] })
        .to eq(%w[iso.inner iec.inner en.overlay national.prefix
                  supplements.core])
      expect(Pubid::BsiPfs::MODULES.first[:identity][:composition])
        .to eq("wrapper-with-adopted")
      expect(Pubid::BsiPfs::MODULES.find { |m| m[:name] == "national.prefix" }[:version]).to eq(1)
    end
  end

  describe "the declared negatives (both flavors reject)" do
    '
      nonsense
      BS 2X 26:2001
      BS 1000[9]:1971
      PD 854a:1951
      BS EN 1073-2:20002
    '.split("\n").map(&:strip).reject(&:empty?).each do |input|
      it "rejects #{input.inspect} with the coded flavor's ParseError" do
        expect { Pubid::Bsi.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
        expect { Pubid::BsiPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  describe "the boundary (the coded flavor accepts them from OTHER " \
           "families; the composition refuses what its model cannot " \
           "represent)" do
    '
      EN 1325
      ISO 9001:2015
      DISC PD 0005:1995
      BS A 103:2025
      BSI Flex 1886 v2.0:2024-09
      BS 7671 AMD2
      BS 1580:Parts 1 and 2:1962
      14/30300822 DC
      NA to BS EN 1996-1-2:2005
      BS 7722:2006 BOOK
      BS 31100:2021 ExComm
      BS 1425:Supplement No. 1:1966
      BS 185 Index:1962
      BS 2782-10:Method 1006:1978
      BS 1902-2.3:Addendum No.  1:1976
      BS CISPR 12:1997
    '.split("\n").map(&:strip).reject(&:empty?).each do |input|
      it "parses #{input.inspect} in the coded flavor, refuses it in the " \
         "composed flavor" do
        expect { Pubid::Bsi.parse(input) }.not_to raise_error
        expect { Pubid::BsiPfs.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end
end
