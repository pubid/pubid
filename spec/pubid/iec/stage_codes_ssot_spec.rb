# frozen_string_literal: true

require "spec_helper"

# The SSOT <-> registry conformance guard for IEC stage codes.
#
# pubid#733's drift class: the typed-stage registry contradicting its own
# stage-code table. The SSOT is data/iec/stage-codes.md — the correspondence
# table of the IEC/ISO Harmonized APIs (identical in v0.0.7 2021-05 and
# v0.0.8 2023-06, provenance in the file header). #733 (4b144082, released
# 2.0.35) aligned registry and table; this spec locks every row of the table
# against the registry in BOTH directions, so the drift cannot be
# reintroduced silently.
#
# The rows come from PARSING the SSOT file — nothing is hand-copied here,
# and the classification-coverage examples make any row added to the file
# without a classification turn red.
#
# Honor forms. Not every row is honored the same way; the form is derived
# from the registry shape and frozen by the shape examples below, so a
# change of shape forces a conscious reclassification:
#
# - POINT — the abbr resolves to a dedicated single-code row whose
#   harmonized list IS the table code. The #733 shape (CDPAS 50.20,
#   ADTR/CDTR/DTRM/NDTR, ADTS/CDTS/DTSM/NDTS) plus PNW (its own row since
#   pubid#360 item 1). This is what carries the code into the official
#   `urn:iec:std:` stage slot.
# - RANGE — the abbr is carried by multi-code ladder rows; the table code
#   must be CONTAINED in the carriers' harmonized lists (the lead may be
#   the registration-step code — the #733 ruling for the folded ladders).
#   CDISH is the union case: carried by the cdish committee-draft row
#   (30.xx) AND as an alias on the dish row whose folded ladder carries
#   50.20; DEL is the two-code case (10.98 on np, 20.98 on wd).
# - PROJECT_ONLY — the abbr lives only in a class's PROJECT_STAGES hash
#   (the per-deliverable stages of the pubid#576 reconciliation round,
#   deliberately queryable but unparseable); the hash entry must carry the
#   table code, and no TYPED_STAGES row may carry the spelling.
# - LADDER_CLAIMED — four rows (ACD 20.99, ACDV 30.99, APUB 50.99, CAN
#   30.98+50.98) whose abbreviation resolves onto a row that does NOT
#   carry the table code, while the code itself is claimed by a
#   harmonized ladder. That is the pubid#576 reconciliation's deliberate
#   honor form ("the codes are claimed by the ladder stages"), locked by
#   stage_reconciliation_spec.rb. The guard keeps BOTH halves: the abbr
#   must resolve, and some typed-stage row must still claim the code.
#   Should a later round promote these spellings onto rows that carry
#   their codes (the #733 treatment), the frozen-shape example goes red
#   and the classification must be updated with the promotion.
# - NO_CODE — SPE: a sourced row IEC's table gives no code ("—"); only
#   the resolution is asserted.
#
# The Meaning column is parsed but not asserted: the registry's `name` is
# descriptive prose, not byte-locked to the table (cdvm is "Rejected CDV
# to be discussed at a meeting", the table says "at meeting"). The
# Deliverable column IS used — as the source of the type-designator set
# the reverse check validates composite rows against.
RSpec.describe "IEC stage-code SSOT conformance (pubid#733 guard)" do
  SSOT_PATH = File.expand_path("../../../data/iec/stage-codes.md", __dir__)

  # ------------------------------------------------------------------
  # The SSOT table, parsed out of data/iec/stage-codes.md
  # ------------------------------------------------------------------
  def self.parse_ssot_table
    body = File.read(SSOT_PATH)
    section = body.split(/^## /).find do |chunk|
      chunk.start_with?("IEC/ISO Stage Code correspondance")
    end
    raise "no 'IEC/ISO Stage Code correspondance' section in #{SSOT_PATH}" unless section

    section.each_line.filter_map do |line|
      next unless line.start_with?("|")

      cells = line.split("|").map(&:strip)[1..]
      next unless cells && cells.size >= 4
      # drop the header row and the |---| separator row
      next if cells[0] == "Harmonized Stage" || cells[0].match?(/\A-+\z/)

      { code: cells[0], abbr: cells[1], meaning: cells[2],
        deliverables: cells[3].split(",").map(&:strip) }
    end
  end

  SSOT_TABLE = parse_ssot_table.freeze
  SSOT_ABRS = SSOT_TABLE.map { |row| row[:abbr] }.uniq.freeze
  SSOT_DESIGNATORS = SSOT_TABLE.flat_map { |row| row[:deliverables] }.uniq.sort.freeze

  # ------------------------------------------------------------------
  # The classification (forward direction). See the header for what
  # each class asserts and where its ruling comes from.
  # ------------------------------------------------------------------
  SSOT_POINT = {
    "PNW"   => "10.20",
    "CDPAS" => "50.20",
    "ADTR"  => "40.99", "CDTR" => "50.20", "DTRM" => "50.92",
    "NDTR"  => "50.92",
    "ADTS"  => "40.99", "CDTS" => "50.20", "DTSM" => "50.92",
    "NDTS"  => "50.92",
  }.freeze

  SSOT_RANGE = {
    "PWI"     => %w[00.00],
    "DEL"     => %w[10.98 20.98], # two table rows: IS/TR/TS and ISH
    "PRVN"    => %w[10.60],
    "CD"      => %w[30.20], "CDM" => %w[30.60], "PCC" => %w[30.60],
    "SPLIT"   => %w[30.96], "MERGED" => %w[30.97],
    "CCDV"    => %w[40.20], "CDVM" => %w[40.91], "NCDV" => %w[40.91],
    "CFDIS"   => %w[50.20], "NFDIS" => %w[50.92],
    "RFDIS"   => %w[50.00], "RDISH" => %w[50.00],
    "CDISH"   => %w[50.20],
    "BPUB"    => %w[60.00], "PPUB" => %w[60.60], "RPUB" => %w[60.00],
    "TPUB"    => %w[60.00], "DECPUB" => %w[60.00], "WPUB" => %w[95.99],
    "DELPUB"  => %w[99.60],
  }.freeze

  SSOT_PROJECT_ONLY = {
    "TCDV"    => %w[40.00],
    "PRVC"    => %w[40.60], "PRVD" => %w[50.60],
    "AFDIS"   => %w[40.99], "DECFDIS" => %w[50.00],
    "DECDISH" => %w[50.00], "PRVDISH" => %w[50.60], "TDISH" => %w[50.00],
    "TDTR"    => %w[50.00], "PRVDTR" => %w[50.60],
    "TDTS"    => %w[50.00], "PRVDTS" => %w[50.60],
    "PRVDPAS" => %w[50.60],
  }.freeze

  SSOT_LADDER_CLAIMED = {
    "ACD"  => %w[20.99],
    "ACDV" => %w[30.99],
    "APUB" => %w[50.99],
    "CAN"  => %w[30.98 50.98], # two table rows: IS/TR/TS and PAS/ISH/COR
  }.freeze

  SSOT_NO_CODE = %w[SPE].freeze

  # ------------------------------------------------------------------
  # The reverse direction: registered spellings outside the table.
  # Each entry documents WHY the spelling exists without a table row.
  # ------------------------------------------------------------------
  SSOT_SKIP = {
    # Preliminary-phase aliases (pwi row): legacy pubid-iec spellings,
    # IEC's table names only PWI 00.00.
    "NWIP" => "legacy preliminary-phase alias on the pwi row; IEC's table names only PWI 00.00",
    "BWG"  => "legacy preliminary-phase alias on the pwi row; IEC's table names only PWI 00.00",
    "AWIN" => "legacy preliminary-phase alias on the pwi row; IEC's table names only PWI 00.00",
    "AMW"  => "legacy preliminary-phase alias on the pwi row; IEC's table names only PWI 00.00",
    # Proposal-phase names: IEC's own IS-lifecycle ladder section in the
    # SSOT chains "PNW/NP"; the correspondence table's proposal row is
    # PNW 10.20.
    "NP"  => "the proposal-phase name IEC's IS-lifecycle ladder chains (SSOT: PNW/NP); the table's proposal row is PNW 10.20",
    "ANW" => "the approved-new-work name; the table's proposal-phase code is PNW 10.20 and no ANW row exists",
    "AWI" => "legacy alias of ANW on the anw row; unsourced",
    # Working-draft phase name (ISO harmonized 20.xx): IEC's table names
    # no WD row — its committee-draft code is CD 30.20.
    "WD" => "the working-draft phase name; IEC's table names no WD row (its committee-draft code is CD 30.20)",
    # Enquiry-phase names: the SSOT's own note — the modern API spells
    # the ladder with the C-prefixed circulation codes.
    "CDV" => "the enquiry-phase name of IEC's ladder; the table's modern codes (ACDV 30.99, CCDV 40.20, CDVM 40.91, NCDV 40.91) are all claimed by the cdv row",
    "DIS" => "bare DIS appears only as the delivered draft (SSOT note); the enquiry circulations are CCDV/TCDV",
    "FDIS" => "bare FDIS appears only as the delivered draft (SSOT note); the approval circulations are CFDIS/RFDIS/NFDIS/DECFDIS, claimed by the fdis row",
    "PRF" => "internal ladder alias on the fdis row; unsourced in IEC's table",
    "NADIS" => "legacy alias on the fdis row; unsourced in IEC's table",
    "ADIS" => "the legacy Data Feeds spelling of AFDIS, documented in this SSOT file's legacy section (STAGE_CODE ADIS, harmonized 40.99); alias on the cdv row whose list covers 40.99",
    # Review sub-state: #237's own list maps RR to 9092; the harmonized
    # system is joint ISO/IEC and IEC's table names no IEC stage codes
    # for the review sub-states (SSOT relationship section).
    "RR" => "review sub-state; #237 maps RR to 9092 and IEC's table names no IEC stage code for the review sub-states (SSOT relationship section)",
    # Committee-draft revision spellings (cd row): the table's CD row is
    # the single 30.20 code.
    "2CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A2CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "3CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A3CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "4CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A4CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "5CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A5CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "6CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A6CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "7CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A7CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "8CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A8CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "9CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    "A9CD" => "committee-draft revision spelling on the cd row; the table's CD row is the single 30.20 code",
    # Plain draft spellings: they keep the folded 50.xx registration
    # ladders (the pubid#733 ruling); IEC's table has no DTR/DTS/DPAS/
    # DISH rows — its per-spelling codes live on the point rows these
    # ladders carry.
    "DTR" => "plain draft spelling keeping the folded 50.xx ladder (pubid#733 ruling); the table's TR draft codes live on the ADTR/CDTR/DTRM/NDTR point rows",
    "DTS" => "plain draft spelling keeping the folded 50.xx ladder (pubid#733 ruling); the table's TS draft codes live on the ADTS/CDTS/DTSM/NDTS point rows",
    "DPAS" => "plain PAS draft spelling keeping the folded 50.xx ladder (pubid#733 ruling); the table's PAS draft row is CDPAS 50.20",
    "DISH" => "plain ISH draft spelling keeping the folded 50.xx ladder; the table's ISH draft row is CDISH 50.20, which this row's ladder carries",
    # Deliverable/type designators: named in the table's Deliverable
    # column, but no stage-code rows of their own.
    "TR" => "deliverable/type designator (the table's Deliverable column); no stage-code row",
    "TS" => "deliverable/type designator (the table's Deliverable column); no stage-code row",
    "PAS" => "deliverable/type designator (the table's Deliverable column); no stage-code row",
    "ISH" => "deliverable/type designator (the table's Deliverable column); no stage-code row",
    "COR" => "deliverable/type designator (the table's Deliverable column); no stage-code row",
    "CS" => "non-stage IEC document-family designator (component specification); no correspondence-table row",
    "OD" => "non-stage IEC document-family designator (operational document); no correspondence-table row",
    "CA" => "non-stage IEC document-family designator (conformity assessment); no correspondence-table row",
    "SRD" => "non-stage IEC document-family designator (systems reference document); no correspondence-table row",
    "TRF" => "non-stage IEC document-family designator (test report form); no correspondence-table row",
    "White Paper" => "whole type name, not a stage; no correspondence-table row",
    "Technology Report" => "whole type name, not a stage; no correspondence-table row",
    "Trend Report" => "whole type name, not a stage; no correspondence-table row",
    # Corrigendum ladder (pubid-iec 1.x): the table has no corrigendum
    # stage rows; COR appears only as a deliverable designator.
    "WDCor" => "corrigendum working-draft ladder spelling (pubid-iec 1.x); the table has no corrigendum stage rows",
    "CDCor" => "corrigendum committee-draft ladder spelling (pubid-iec 1.x); the table has no corrigendum stage rows",
    "CDCOR" => "the all-caps CDCor spelling the attached-supplement renderer emits; the table has no corrigendum stage rows",
    "DCOR" => "corrigendum draft ladder spelling (pubid-iec 1.x); the table has no corrigendum stage rows",
    "FDCOR" => "corrigendum final-draft ladder spelling (pubid-iec 1.x); the table has no corrigendum stage rows",
    "Cor" => "published-corrigendum type designator; the table names COR only as a deliverable",
    # Amendment ladder (pubid-iec 1.x): the table has no amendment rows.
    "CDAM" => "amendment committee-draft ladder spelling (pubid-iec 1.x); the table has no amendment stage rows",
    "PDAM" => "amendment proposed-draft ladder spelling (pubid-iec 1.x); the table has no amendment stage rows",
    "DAM" => "amendment draft ladder spelling (pubid-iec 1.x); the table has no amendment stage rows",
    "FDAM" => "amendment final-draft ladder spelling (pubid-iec 1.x); the table has no amendment stage rows",
    "FPDAM" => "amendment final-proposed ladder spelling (pubid-iec 1.x); the table has no amendment stage rows",
    "Amd" => "published-amendment type designator; the table has no amendment stage rows",
    "AMD" => "published-amendment type designator (all-caps spelling); the table has no amendment stage rows",
    # Fragment ladder (pubid-iec 1.x): the table names the fragmentation
    # events (SPLIT 30.96 / MERGED 30.97) but no fragment spellings.
    "CDFRAG" => "fragment committee-draft ladder spelling (pubid-iec 1.x); the table names SPLIT/MERGED, not fragment spellings",
    "DFRAG" => "fragment draft ladder spelling (pubid-iec 1.x); the table names SPLIT/MERGED, not fragment spellings",
    "FDFRAG" => "fragment final-draft ladder spelling (pubid-iec 1.x); the table names SPLIT/MERGED, not fragment spellings",
    "FRAG" => "published-fragment type designator; the table names SPLIT/MERGED, not fragment spellings",
    # Guide ladder (pubid-iec 1.x): no guide rows in the table.
    "DGuide" => "guide draft ladder spelling (pubid-iec 1.x); the table has no guide stage rows",
    "FDGuide" => "guide final-draft ladder spelling (pubid-iec 1.x); the table has no guide stage rows",
    "GUIDE" => "guide type designator; the table has no guide stage rows",
    "Guide" => "guide type designator; the table has no guide stage rows",
  }.freeze

  # Supplement-type designators: pubid's own supplement families, outside
  # the correspondence table's Deliverable column (which names only
  # IS/TR/TS/PAS/ISH/COR). Used to validate composite two-token rows.
  SUPPLEMENT_DESIGNATORS = %w[Amd Cor Frag Guide].freeze
  TYPE_DESIGNATORS = (SSOT_DESIGNATORS + SUPPLEMENT_DESIGNATORS).freeze

  REGISTERED_ABRS = (Pubid::Iec.all_typed_stages + Pubid::Iec.all_project_stages)
                    .flat_map { |row| row.abbr.map(&:to_s) }
                    .reject(&:empty?).uniq.sort.freeze

  # ------------------------------------------------------------------
  # Helpers
  # ------------------------------------------------------------------

  def registry_carriers(abbr)
    (Pubid::Iec.all_typed_stages + Pubid::Iec.all_project_stages)
      .select { |row| row.abbr.map { |a| a.to_s.upcase }.include?(abbr) }
  end

  # Called at load time from the per-row example generation, so a
  # singleton method on the example group.
  def self.classified_kind(abbr)
    if SSOT_POINT.key?(abbr)
      :point
    elsif SSOT_RANGE.key?(abbr)
      :range
    elsif SSOT_PROJECT_ONLY.key?(abbr)
      :project_only
    elsif SSOT_LADDER_CLAIMED.key?(abbr)
      :ladder_claimed
    elsif SSOT_NO_CODE.include?(abbr)
      :no_code
    end
  end

  # Two-token spellings ("CD TR", "PWI Amd"): the stage token must be
  # table-sourced or skip-listed, the type token must be a documented
  # designator. Whole spellings that are themselves table-sourced or
  # skip-listed pass unchanged. Returns a problem string, or nil when
  # the composite is accounted for.
  def composite_problem(abbr)
    return if SSOT_ABRS.include?(abbr.upcase) || SSOT_SKIP.key?(abbr)
    return unless abbr.include?(" ")

    head, tail = abbr.split(" ", 2)
    unless SSOT_ABRS.include?(head.upcase) || SSOT_SKIP.key?(head) ||
           SSOT_SKIP.key?(head.upcase)
      return "#{abbr}: composite stage token '#{head}' is neither " \
             "table-sourced nor skip-listed"
    end
    return if TYPE_DESIGNATORS.include?(tail)

    "#{abbr}: composite type token '#{tail}' is not a documented " \
      "designator (#{TYPE_DESIGNATORS.join('/')})"
  end

  # ------------------------------------------------------------------
  # Parser sanity — the extraction must stay the shape the guard assumes
  # ------------------------------------------------------------------

  it "parses the correspondence table the provenance documents" do
    # v0.0.7 + v0.0.8, section 3: 53 rows (52 coded + the no-code SPE row).
    # Bump consciously together with a new extraction.
    expect(SSOT_TABLE.length).to eq(53)
    SSOT_TABLE.each do |row|
      expect(row[:abbr]).to match(/\A[A-Z0-9]+\z/),
        "table abbr #{row[:abbr].inspect} is not a single token"
      code_shape = match(/\A\d{2}\.\d{2}\z/).or eq("—")
      expect(row[:code]).to code_shape,
        "table code #{row[:code].inspect} for #{row[:abbr]} is not XX.XX or —"
    end
  end

  it "grounds the type designators in the table's Deliverable column" do
    expect(SSOT_DESIGNATORS).to contain_exactly("IS", "TR", "TS", "PAS", "ISH", "COR")
  end

  # ------------------------------------------------------------------
  # Classification coverage — no SSOT row outside the classification,
  # no classification entry without an SSOT row
  # ------------------------------------------------------------------

  it "classifies every row of the table" do
    classified = (SSOT_POINT.keys + SSOT_RANGE.keys + SSOT_PROJECT_ONLY.keys +
                  SSOT_LADDER_CLAIMED.keys + SSOT_NO_CODE)
    unclassified = SSOT_ABRS - classified
    expect(unclassified).to(eq([]),
      "SSOT rows with no honor-form classification: #{unclassified.join(', ')}")
  end

  it "classifies nothing that is not in the table" do
    classified = (SSOT_POINT.keys + SSOT_RANGE.keys + SSOT_PROJECT_ONLY.keys +
                  SSOT_LADDER_CLAIMED.keys + SSOT_NO_CODE)
    stale = classified - SSOT_ABRS
    expect(stale).to(eq([]),
      "classification entries absent from the SSOT table (stale map): #{stale.join(', ')}")
  end

  it "classifies each abbreviation exactly once" do
    classified = (SSOT_POINT.keys + SSOT_RANGE.keys + SSOT_PROJECT_ONLY.keys +
                  SSOT_LADDER_CLAIMED.keys + SSOT_NO_CODE)
    duplicated = classified.group_by { |a| a }.select { |_, v| v.size > 1 }.keys
    expect(duplicated).to(eq([]),
      "abbreviations with more than one honor form: #{duplicated.join(', ')}")
  end

  # ------------------------------------------------------------------
  # Forward direction — every sourced row, per row
  # ------------------------------------------------------------------

  SSOT_TABLE.each do |row|
    abbr = row[:abbr]
    code = row[:code]
    kind = classified_kind(abbr)

    describe "SSOT row #{abbr} #{code} (#{kind})" do
      it "is honored by the registry" do
        case kind
        when :point
          # The dedicated single-code row's harmonized list IS the code —
          # this is what carries the code into the official URN slot.
          stage = Pubid::Iec.locate_stage(abbr)
          expect(stage).not_to be_nil, "#{abbr} does not resolve"
          expect(stage.harmonized_stages.map(&:to_s)).to(eq([code]),
            "#{abbr}: the dedicated row must carry exactly #{code}, " \
            "got #{stage.harmonized_stages.map(&:to_s).inspect}")
        when :range
          expect(Pubid::Iec.locate_stage(abbr)).not_to be_nil,
            "#{abbr} does not resolve"
          missing = SSOT_RANGE.fetch(abbr).reject do |c|
            registry_carriers(abbr)
              .any? { |r| r.harmonized_stages.map(&:to_s).include?(c) }
          end
          carrier_names = registry_carriers(abbr)
            .map { |r| "#{r.type_code}/#{r.code}" }.join(", ")
          expect(missing).to(eq([]),
            "#{abbr}: table code(s) #{missing.join(', ')} not contained in " \
            "any registry row carrying the spelling (carriers: " \
            "#{carrier_names})")
        when :project_only
          entries = Pubid::Iec.identifier_types.filter_map do |klass|
            next unless klass.const_defined?(:PROJECT_STAGES)

            klass.const_get(:PROJECT_STAGES).values.find do |entry|
              Array(entry[:abbr]).map { |a| a.to_s.upcase }.include?(abbr)
            end
          end
          expect(entries).not_to be_empty, "#{abbr} has no PROJECT_STAGES entry"
          uncovered = SSOT_PROJECT_ONLY.fetch(abbr).reject do |c|
            entries.any? { |e| e[:harmonized_stages].include?(c) }
          end
          expect(uncovered).to(eq([]),
            "#{abbr}: PROJECT_STAGES entry does not carry table code(s) " \
            "#{uncovered.join(', ')}")
        when :ladder_claimed
          # The #576 honor form: the abbr resolves, and the code is
          # claimed by the ladder stages.
          expect(Pubid::Iec.locate_stage(abbr)).not_to be_nil,
            "#{abbr} does not resolve"
          SSOT_LADDER_CLAIMED.fetch(abbr).each do |c|
            claimed = Pubid::Iec.all_typed_stages.any? do |r|
              r.harmonized_stages.map(&:to_s).include?(c)
            end
            expect(claimed).to(be(true),
              "#{abbr}: table code #{c} is no longer claimed by any " \
              "typed-stage ladder (the #576 honor form is broken)")
          end
        else # :no_code
          expect(Pubid::Iec.locate_stage(abbr)).not_to be_nil,
            "#{abbr} does not resolve"
        end
      end
    end
  end

  # ------------------------------------------------------------------
  # Frozen shapes — the classification must still match the registry
  # ------------------------------------------------------------------

  it "keeps the POINT spellings on dedicated single-code rows" do
    drifted = SSOT_POINT.keys.reject do |abbr|
      stage = Pubid::Iec.locate_stage(abbr)
      stage && stage.harmonized_stages.length == 1
    end
    expect(drifted).to(eq([]),
      "these spellings no longer sit on single-code rows — " \
      "reclassify them (#{drifted.join(', ')})")
  end

  it "keeps the RANGE spellings on multi-code ladder rows" do
    drifted = SSOT_RANGE.keys.select do |abbr|
      stage = Pubid::Iec.locate_stage(abbr)
      stage && stage.harmonized_stages.length == 1
    end
    expect(drifted).to(eq([]),
      "these spellings now resolve to single-code rows — promote them to " \
      "POINT in the classification (#{drifted.join(', ')})")
  end

  it "keeps the PROJECT_ONLY spellings out of TYPED_STAGES" do
    promoted = SSOT_PROJECT_ONLY.keys.select do |abbr|
      carriers = registry_carriers(abbr) - Pubid::Iec.all_project_stages
      carriers.any?
    end
    expect(promoted).to(eq([]),
      "these spellings gained TYPED_STAGES rows (the #733 promotion) — " \
      "reclassify them as POINT or RANGE (#{promoted.join(', ')})")
  end

  it "keeps the LADDER_CLAIMED spellings on rows that claim none of their codes" do
    # If a carrier starts carrying the table code, the honor form has
    # changed — update the classification with the promotion.
    overlapping = SSOT_LADDER_CLAIMED.flat_map do |abbr, codes|
      codes.select do |c|
        registry_carriers(abbr)
          .any? { |r| r.harmonized_stages.map(&:to_s).include?(c) }
      end.map { |c| "#{abbr} #{c}" }
    end
    expect(overlapping).to(eq([]),
      "these spellings now sit on rows carrying their table codes — " \
      "reclassify as POINT/RANGE (#{overlapping.join(', ')})")
  end

  # ------------------------------------------------------------------
  # Reverse direction — every registered spelling accounted for
  # ------------------------------------------------------------------

  it "registers no abbreviation outside the SSOT table and the documented skips" do
    unexplained = REGISTERED_ABRS.filter_map do |abbr|
      next nil if SSOT_ABRS.include?(abbr.upcase)
      next nil if SSOT_SKIP.key?(abbr)

      # composite_problem accounts for the two-token spellings and names
      # the offending part; a lone token has no composite to fall back on.
      if abbr.include?(" ")
        composite_problem(abbr)
      else
        "#{abbr}: registered but neither table-sourced nor skip-listed"
      end
    end
    expect(unexplained).to(
      eq([]),
      "registered spellings the SSOT conformance cannot account for:\n" \
      "#{unexplained.join("\n")}",
    )
  end

  it "has no stale skip-list entry" do
    stale = SSOT_SKIP.keys - REGISTERED_ABRS
    expect(stale).to(eq([]),
      "skip-list entries for spellings no longer registered (drop them): " \
      "#{stale.join(', ')}")
  end

  it "documents a reason for every skip-list entry" do
    reasonless = SSOT_SKIP.select { |_, reason| reason.nil? || reason.empty? }.keys
    expect(reasonless).to(eq([]),
      "skip-list entries without a documented reason: #{reasonless.join(', ')}")
  end

  it "documents the composite rows through their parts" do
    problems = REGISTERED_ABRS.filter_map { |abbr| composite_problem(abbr) }
    expect(problems).to(
      eq([]),
      "composite rows not accounted for by their parts:\n#{problems.join("\n")}",
    )
  end
end
