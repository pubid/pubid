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
# MEASURED LEDGER (2026-11, parsanol 1.3.126, grammar origin/main with
# the #121 declared-emission features):
#
#   absorbed    304 / 1,500 — the plain BS face (numbers with glued
#               letters, dashed/dotted/multi-level parts, years) at byte
#               parity on every identity surface (class, to_s, to_hash,
#               to_urn, to_pubid_urn, to_mr_string) plus from_hash
#               round-trip.
#   classified  539 — rows the composed flavor PARSES with the right
#               class and the printed face (to_s), whose SERIALIZATION
#               carries coded-flavor machinery the declared emission does
#               not fill. Four named divergence families, each a
#               follow-up on the module library / the generated emission
#               (see BOUNDARY below):
#
#     wrapper-emission  393 (the adoption rows + the plus-run
#               consolidated rows) — to_hash carries `adopted` where the
#               coded wrapper renamed the slot to the uniform `base`
#               (and the DD-adoption rows keep the nested
#               `{"body" => "DD"}` publisher the cen flat-scalar table
#               flattens); to_urn reads the ROOT document's identity
#               (urn:bsi:bs:1073:-2:2002) — a root-through read the
#               ordered segment declaration does not carry;
#               to_pubid_urn RAISES — the codec composes nested nodes
#               root-first along `base`, the generated adopted attribute
#               is (hard-coded) `adopted`; to_mr_string fuses the
#               adopted MR (bs.en.1073-2.2002) where the coded
#               RootIdentity slug reads the root number
#               (bs.1073-2.2002), and the coded consolidated slug drops
#               the member suffixes the generated one appends.
#     typed-trio        146 (the PAS/PD/DD/TS designation rows) — the
#               coded rows serialize type/stage/typed_stage with names,
#               type_codes and harmonized_stages the type declaration
#               (code/stage_code/abbr) cannot express; the coded URN
#               appends the type abbr and ":stage.published" (a
#               string-vs-symbol comparison in the coded generator).
#     printed-face      1 — "BS HD IEC 60364-8-81 ED1": the ED edition
#               face stays inside the delegated cen parse, whose render
#               drops it (the coded flavor carries the edition column).
#
#   unabsorbed  657 — rows outside the composition surface, rejected
#               (ParseError, never a wrong class): the thirty-plus coded
#               families the module library does not model (aerospace,
#               Flex, committee documents, index/method/section/test
#               suffixes, addenda/supplements, national annexes, Expert
#               commentary, bundles, sets, standalone AMD, value-added
#               wrappers, DISC escalation prefix) and four declared
#               shapes (the AMD keyword supplement spelling, the
#               second_number slash column, the CISPR aerospace routing,
#               the "(Book)" / "(R2004)" parenthetical suffixes).
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
        expect(pfs.to_mr_string).to eq(coded.to_mr_string)
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
    "adopted_european_norm" => { absorbed: 0,
                                 classified: {
                                   "to_hash+to_urn+to_pubid_urn+to_mr_string" => 266,
                                   "to_s+to_hash+to_urn+to_pubid_urn+to_mr_string" => 1,
                                 },
                                 unabsorbed: 0 },
    "adopted_international_standard" => { absorbed: 0,
                                          classified: {
                                            "to_hash+to_urn+to_pubid_urn+to_mr_string" => 74,
                                          },
                                          unabsorbed: 7 },
    "aerospace_standard" => { absorbed: 0, classified: {}, unabsorbed: 339 },
    "british_standard" => { absorbed: 304, classified: {}, unabsorbed: 42 },
    "bundled_identifier" => { absorbed: 0, classified: {}, unabsorbed: 27 },
    "committee_document" => { absorbed: 0, classified: {}, unabsorbed: 6 },
    "consolidated_identifier" => { absorbed: 0,
                                   classified: {
                                     "to_hash+to_urn+to_pubid_urn+to_mr_string" => 52,
                                   },
                                   unabsorbed: 46 },
    "detailed_specification" => { absorbed: 0, classified: {}, unabsorbed: 16 },
    "disc" => { absorbed: 0, classified: {}, unabsorbed: 9 },
    "draft_document" => { absorbed: 0,
                          classified: {
                            "to_hash+to_urn+to_pubid_urn+to_mr_string" => 13,
                          },
                          unabsorbed: 0 },
    "expert_commentary" => { absorbed: 0, classified: {}, unabsorbed: 25 },
    "explanatory_supplement" => { absorbed: 0, classified: {}, unabsorbed: 1 },
    "flex" => { absorbed: 0, classified: {}, unabsorbed: 23 },
    "index" => { absorbed: 0, classified: {}, unabsorbed: 13 },
    "method" => { absorbed: 0, classified: {}, unabsorbed: 14 },
    "national_annex" => { absorbed: 0, classified: {}, unabsorbed: 18 },
    "publicly_available_specification" => { absorbed: 0,
                                            classified: {
                                              "to_hash+to_urn+to_pubid_urn+to_mr_string" => 56,
                                            },
                                            unabsorbed: 0 },
    "published_document" => { absorbed: 0,
                              classified: {
                                "to_hash+to_urn+to_pubid_urn+to_mr_string" => 74,
                              },
                              unabsorbed: 2 },
    "section" => { absorbed: 0, classified: {}, unabsorbed: 11 },
    "set" => { absorbed: 0, classified: {}, unabsorbed: 1 },
    "standalone_amendment" => { absorbed: 0, classified: {}, unabsorbed: 4 },
    "supplement_document" => { absorbed: 0, classified: {}, unabsorbed: 18 },
    "supplementary_index" => { absorbed: 0, classified: {}, unabsorbed: 1 },
    "technical_specification" => { absorbed: 0,
                                   classified: {
                                     "to_hash+to_urn+to_pubid_urn+to_mr_string" => 3,
                                   },
                                   unabsorbed: 0 },
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

  it "absorbs the composed BS face (304 rows) at full byte parity" do
    absorbed_total = measured.values.sum { |g| g[:absorbed].size }
    expect(absorbed_total).to eq(304)
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
      # the adopted document is the base of the wrapper (the identity
      # composition the modules declare)
      expect(id.adopted).to be_a(Pubid::CenCenelec::Identifier)
    end

    it "the multi-level chain: BS EN ISO is a BSI wrapper over a CEN " \
       "adoption over the ISO document" do
      id = Pubid::BsiPfs.parse("BS EN ISO 105-B06:2020")
      expect(id).to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      expect(id.adopted).to be_a(Pubid::CenCenelec::Identifier)
      expect(id.adopted.adopted).to be_a(Pubid::Iso::Identifier)
      expect(id.to_s).to eq("BS EN ISO 105-B06:2020")
    end

    it "iso.inner and iec.inner as the adopted inners (BS ISO / BS IEC)" do
      iso = Pubid::BsiPfs.parse("BS ISO 8601:2019")
      expect(iso).to be_a(Pubid::BsiPfs::Identifiers::AdoptedInternationalStandard)
      expect(iso.adopted).to be_a(Pubid::Iso::Identifier)
      expect(iso.to_s).to eq("BS ISO 8601:2019")

      iec = Pubid::BsiPfs.parse("BS IEC 60747-8:2000")
      expect(iec.adopted).to be_a(Pubid::Iec::Identifier)
      expect(iec.to_s).to eq("BS IEC 60747-8:2000")
    end

    it "the national head over the DD/PD designations adopting CEN documents" do
      dd = Pubid::BsiPfs.parse("DD CEN ISO/TS 12180-1:2007")
      expect(dd).to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      expect(dd.adopted).to be_a(Pubid::CenCenelec::Identifier)
      expect(dd.to_s).to eq("DD CEN ISO/TS 12180-1:2007")
    end

    it "the IEC-internal runs stay inside the delegated adoption" do
      frag = Pubid::BsiPfs.parse("BS EN IEC 60601-1/FRAG1")
      expect(frag.to_s).to eq("BS EN IEC 60601-1/FRAG1")
      expect(frag.adopted.adopted).to be_a(Pubid::Iec::Identifier)

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
      # the generated consolidated URN marks each member with the plus
      # marker (the cen shape); the coded BSI generator omits it — the
      # classified to_urn divergence family
      expect(plain.to_urn).to eq("urn:bsi:bs:10125:2014:plus:amd:1:2016")

      adopted = Pubid::BsiPfs.parse("BS EN 1005-1:2001+A1:2008")
      expect(adopted).to be_a(Pubid::BsiPfs::Identifiers::ConsolidatedIdentifier)
      expect(adopted.identifiers.first)
        .to be_a(Pubid::BsiPfs::Identifiers::AdoptedEuropeanNorm)
      expect(adopted.to_s).to eq("BS EN 1005-1:2001+A1:2008")
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
      AMD 11015
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
