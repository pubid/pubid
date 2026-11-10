# frozen_string_literal: true

require "spec_helper"

# The relaton-index contract for IEC, plus the serialization fix for the
# three families that kept their identity in attributes no key_value map
# covered (issue #687).
#
# Relaton::Index::Type#candidates_by_number sorts and bsearches every index
# row on `id.root.number.to_s`, and `#matches?` is
# `exclude(*ignore) == other.exclude(*ignore)`. Three IEC families kept
# their identity in attributes nothing serialized, so `to_s` was correct
# while `to_hash` was not:
#
#   * `WorkingDocument` (`1/2457/FDIS`): `technical_committee`, `wd_number`,
#     `wd_stage`, `wd_language` — `to_hash` was
#     `{"_type" => "pubid:iec:working-document"}`, all 2,318 documents
#     shared one hash and one type-only URN (`urn:pubid:iec:wd`), and
#     `root.number` keyed the empty string;
#   * the work-programme form of the same class (`PWI TR 100-36 ED1`):
#     `wp_stage`/`wp_type`, with `wp_type` holding a trailing space the
#     renderer stripped;
#   * `TestReportForm` (`IECEE TRF CISPR 11A:2008`): the nested
#     `cispr_identifier`.
#
# Over the IEC pass fixtures that was 2,388 of 12,331 ids not `==` after a
# from_hash(to_hash) round trip — silently, with no error. The fix maps the
# attributes (lutaml key_value declarations only), moves `wd_number` into
# the inherited `number`, strips `wp_type` at the construction site, and
# adds the matching pubid-scheme URN atoms. Locked here.
module IecIndexKeySpec
  # printed reference => [leaf class, index key]
  KEYS = {
    # working document: the document's own number IS `number` (issue #687:
    # it used to sit in a parallel `wd_number` attribute nothing serialized)
    "1/2457/FDIS" => ["WorkingDocument", "2457"],
    "100/3705(F)/FDIS" => ["WorkingDocument", "3705"],
    "JTC1-SC41/289/CC" => ["WorkingDocument", "289"],
    # work-programme form: the committee occupies `number` and the item the
    # `part` ("PNW 1-1597" → number "1", part "1597"). That is the shape this
    # form already had on main, and the #687 open-question-1 ruling ("number
    # holds wd_number, the committee is a separate column") follows the
    # existing code rather than re-keying it — so the two forms of one class
    # use `number` differently. The asymmetry is recorded in
    # lib/pubid/iec/CLAUDE.md.
    "PNW 1-1597 ED1" => ["WorkingDocument", "1"],
    "PWI TR 100-36 ED1" => ["WorkingDocument", "100"],
    # a TRF with a number of its own keys on it
    "IECEE TRF 10079-1A:2020" => ["TestReportForm", "10079"],
    # a plain standard, for contrast
    "IEC 60050:2011" => ["InternationalStandard", "60050"],
  }.freeze

  # The six #687 references: one per family member named in the issue.
  ROUND_TRIP_REFERENCES = [
    "1/2457/FDIS",
    "100/3705(F)/FDIS",
    "JTC1-SC41/289/CC",
    "PNW 1-1597 ED1",
    "PWI TR 100-36 ED1",
    "IECEE TRF CISPR 11A:2008",
  ].freeze

  # Every pass fixture line, deduplicated. The acceptance sweep: pass/ is
  # the corpus that must parse AND round-trip (fail/ must not parse; full/
  # is the conservation source).
  FIXTURE_LINES = Dir
    .glob(File.join(__dir__, "../../fixtures/iec/identifiers/pass/*.txt"))
    .flat_map { |f| File.readlines(f, chomp: true) }
    .map(&:strip).reject(&:empty?).reject { |l| l.start_with?("#") }
    .uniq.freeze

  def self.parsed_corpus
    @parsed_corpus ||= FIXTURE_LINES.filter_map do |line|
      id = begin
        Pubid::Iec.parse(line)
      rescue StandardError, Pubid::Errors::ParseError
        nil
      end
      [line, id] if id
    end
  end

  # A CISPR-bearing TestReportForm keys the empty string BY DECISION (#687
  # open-question-2 ruling): a TRF is a form ABOUT the CISPR document, not
  # a wrapper of it, so `#root` stays the form and `cispr_identifier` is
  # serialized instead.
  def self.cispr_test_report?(id)
    id.is_a?(Pubid::Iec::Identifiers::TestReportForm) && id.cispr_identifier
  end
end

RSpec.describe "Pubid::Iec index key (root.number) and #687 serialization" do
  describe "structural tripwire" do
    it "no longer declares a parallel wd_number attribute" do
      expect(Pubid::Iec::Identifiers::WorkingDocument.attributes)
        .not_to have_key(:wd_number)
    end

    it "resolves the inherited `number` to a String" do
      expect(Pubid::Iec::Identifier.attributes[:number].type)
        .to eq(Lutaml::Model::Type::String)
    end

    it "maps the working document's identity attributes" do
      mapped = Pubid::Iec::Identifiers::WorkingDocument.mappings_for(:hash)
        .mappings.map(&:name)
      %w[technical_committee wd_language wd_stage wp_stage wp_type]
        .each { |key| expect(mapped).to include(key) }
    end

    it "maps the test report form's nested CISPR identifier" do
      mapped = Pubid::Iec::Identifiers::TestReportForm.mappings_for(:hash)
        .mappings.map(&:name)
      expect(mapped).to include("cispr_identifier")
    end

    it "strips wp_type at the construction site, not at render time" do
      # The grammar captures "PWI TR 100-36" with a trailing space on the
      # type token; the builder stores it stripped, so to_hash and the URN
      # carry what renders.
      id = Pubid::Iec.parse("PWI TR 100-36 ED1")
      expect(id.wp_type).to eq("TR")
      expect(id.to_hash["wp_type"]).to eq("TR")
    end
  end

  describe "per-type index key" do
    IecIndexKeySpec::KEYS.each do |ref, (klass, key)|
      context ref do
        subject(:id) { Pubid::Iec.parse(ref) }

        it "is a #{klass}" do
          expect(id.class.name.split("::").last).to eq(klass)
        end

        it "keys on #{key.inspect}" do
          expect(id.root.number.to_s).to eq(key)
        end
      end
    end

    context "IECEE TRF CISPR 11A:2008 (ruling: #root stays the form)" do
      subject(:id) { Pubid::Iec.parse("IECEE TRF CISPR 11A:2008") }

      it "leaves #root the form, not the CISPR document" do
        expect(id.root).to eq(id)
        expect(id.root.number).to be_nil
      end

      it "serializes the CISPR document it is about" do
        expect(id.to_hash["cispr_identifier"]).to eq(
          "_type" => "pubid:iec:international-standard",
          "publisher" => "CISPR",
          "number" => "11A",
        )
      end
    end
  end

  describe "the #687 references restore an equal identifier" do
    IecIndexKeySpec::ROUND_TRIP_REFERENCES.each do |ref|
      it ref do
        id = Pubid::Iec.parse(ref)

        expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
      end
    end

    it "builds the same working document through the constructor and parse" do
      # The number_string lesson: two construction paths must be compared
      # with ==, not only by their renderings — the wd form's document
      # number lives on the inherited `number`, the one attribute the
      # parse and constructor paths must agree on.
      constructed = Pubid::Iec::Identifiers::WorkingDocument.new(
        technical_committee: "1", number: "2457", wd_stage: "FDIS",
      )

      expect(constructed).to eq(Pubid::Iec.parse("1/2457/FDIS"))
    end
  end

  describe "the whole pass-fixture corpus" do
    it "parses a corpus worth sweeping" do
      expect(IecIndexKeySpec.parsed_corpus.size).to be > 12_000
    end

    it "restores an equal identifier from every parseable id" do
      bad = IecIndexKeySpec.parsed_corpus.reject do |_, id|
        Pubid::Iec::Identifier.from_hash(id.to_hash) == id
      end
      expect(bad.map(&:first).first(10)).to eq([])
    end

    it "gives every identifier a non-empty root.number, TRFs ruled out" do
      bad = IecIndexKeySpec.parsed_corpus.reject do |_, id|
        IecIndexKeySpec.cispr_test_report?(id) || !id.root.number.to_s.empty?
      end
      expect(bad.map(&:first).first(10)).to eq([])
    end

    it "gives every CISPR-bearing TRF a serialized CISPR document" do
      bad = IecIndexKeySpec.parsed_corpus.reject do |_, id|
        next true unless IecIndexKeySpec.cispr_test_report?(id)

        id.to_hash.key?("cispr_identifier") &&
          Pubid::Iec::Identifier.from_hash(id.to_hash) == id
      end
      expect(bad.map(&:first).first(10)).to eq([])
    end

    it "gives every working document its own pubid-scheme URN" do
      # Before #687 all 2,318 working documents shared the type-only
      # `urn:pubid:iec:wd`.
      urns = IecIndexKeySpec.parsed_corpus
        .select { |_, id| id.is_a?(Pubid::Iec::Identifiers::WorkingDocument) }
        .map { |_, id| id.to_pubid_urn }
      expect(urns.uniq.size).to eq(urns.size)
      expect(urns.first).to start_with("urn:pubid:iec:wd:")
    end
  end
end
