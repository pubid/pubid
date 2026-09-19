# frozen_string_literal: true

require "spec_helper"

# The relaton-index contract for ASME, plus the structural tripwire for the
# `number` attribute.
#
# Relaton::Index::Type#candidates_by_number sorts and bsearches every index row
# on `id.root.number.to_s`. ASME kept identity in an Asme::Components::Code
# under a `code` attribute and never set the `number` it inherits from
# ::Pubid::Identifier, so all 731 parseable fixture ids keyed "".
#
# Asme::Components::Code is NOT a subclass of Pubid::Components::Code, so naming
# the attribute `number` retypes the inherited one — the multi-flavor
# determinism landmine. It is therefore declared on the concrete LEAF
# (Identifiers::Standard) and never on SingleIdentifier or Identifiers::Base,
# which it inherits from. Only meaningful under the full `bundle exec rake`.
#
# `number` holds the WHOLE printed code ("B18.3", "BPVC-CC-BPV"), NOT a
# designator/number split. The split cannot key this corpus: 152 of the 731
# fixture ids are Boiler and Pressure Vessel Code documents whose entire
# identity is the designator, with no numeric part to split off. See the
# comment on Identifiers::Standard#number.
#
# Carries ASME's corpus sweep too: spec/pubid/asme/fixtures_spec.rb globs
# "../../../fixtures/ASME/..." and reports 0 examples (hand-off
# ten-dead-fixture-specs).
module AsmeIndexKeySpec
  # printed reference => index key (the WHOLE printed code)
  KEYS = {
    "ASME B18.3-2012" => "B18.3",
    "ASME A112.19.12-2006" => "A112.19.12",
    "ASME Y14.43-2011" => "Y14.43",
    "ASME A112.19.1/CSA B45.2-2018" => "A112.19.1",
    # Boiler and Pressure Vessel Code documents have no numeric part at all —
    # their whole identity is the designator. Keying on the whole code is what
    # lets these 152 corpus ids have a key rather than an empty string.
    "ASME BPVC-CC-BPV-2019" => "BPVC-CC-BPV",
    "ASME BPVC COMPLETE CODE BIND-2019" => "BPVC COMPLETE CODE BIND",
  }.freeze

  FIXTURE_LINES = Dir
    .glob(File.join(__dir__, "../../fixtures/asme/**/*.txt"))
    .reject { |f| f.include?("/fail/") }
    .flat_map { |f| File.readlines(f, chomp: true) }
    .map(&:strip).reject(&:empty?).reject { |l| l.start_with?("#") }
    .uniq.freeze

  def self.parsed_corpus
    @parsed_corpus ||= FIXTURE_LINES.filter_map do |line|
      id = begin
        Pubid::Asme.parse(line)
      rescue StandardError, Parslet::ParseFailed
        nil
      end
      [line, id] if id
    end
  end
end

RSpec.describe "Pubid::Asme index key (root.number)" do
  describe "structural tripwire (full-suite only)" do
    it "declares `number` as a String on the Standard LEAF" do
      expect(Pubid::Asme::Identifiers::Standard.attributes[:number].type)
        .to eq(Lutaml::Model::Type::String)
    end

    it "resolves the inherited-from classes' `number` to a String" do
      [Pubid::Asme::Identifier, Pubid::Asme::SingleIdentifier,
       Pubid::Asme::Identifiers::Base].each do |klass|
        expect(klass.attributes[:number].type).to eq(Lutaml::Model::Type::String)
      end
    end

    it "no longer declares a `code` attribute" do
      expect(Pubid::Asme::SingleIdentifier.attributes).not_to have_key(:code)
      expect(Pubid::Asme::Identifiers::Standard.attributes)
        .not_to have_key(:code)
    end
  end

  describe "per-type index key" do
    AsmeIndexKeySpec::KEYS.each do |ref, number|
      context ref do
        subject(:id) { Pubid::Asme.parse(ref) }

        it "keys on #{number.inspect}" do
          expect(id.root.number.to_s).to eq(number)
        end

        it "renders the printed code from the number alone" do
          expect(id.to_s).to include(number)
        end
      end
    end
  end

  describe "the whole fixture corpus" do
    it "parses a corpus worth sweeping" do
      expect(AsmeIndexKeySpec.parsed_corpus.size).to be >= 731
    end

    it "gives every identifier a non-empty root.number" do
      bad = AsmeIndexKeySpec.parsed_corpus.select do |_, id|
        id.root.number.to_s.empty?
      end
      expect(bad.map(&:first).first(5)).to eq([])
    end

    it "round-trips every identifier through from_hash(to_hash)" do
      bad = AsmeIndexKeySpec.parsed_corpus.select do |_, id|
        h = id.to_hash
        Pubid::Asme::Identifier.from_hash(h).to_hash != h
      end
      expect(bad.map(&:first).first(5)).to eq([])
    end

    # to_slug is an output FILENAME. Before the index columns landed all 731
    # ids collapsed onto five slugs, 722 of them sharing "asme".
    it "gives every identifier a non-empty, filename-safe MR slug" do
      slugs = AsmeIndexKeySpec.parsed_corpus.map { |_, id| id.to_mr_string }
      expect(slugs.count(&:empty?)).to eq(0)
      expect(slugs.grep(/[^a-z0-9._-]/).first(5)).to eq([])
      # "_" separates supplement layers in the MR format
      # (Pubid::Parsers::MrString splits on it first); ASME has none.
      expect(slugs.grep(/_/).first(5)).to eq([])
    end

    it "gives distinct identifiers distinct slugs" do
      by_slug = AsmeIndexKeySpec.parsed_corpus
        .group_by { |_, id| id.to_mr_string }
      clashing = by_slug.reject do |_, rows|
        rows.map { |_, id| id.to_hash }.uniq.size == 1
      end
      expect(clashing.keys).to eq([])
    end

    # A designator with no number ("BPVC.I", "BPE", "OM", "PASE") used to lose
    # its year: the dash branch of `number_part` took "-2021" as the number,
    # and the BPVC builder then discarded that number. All 150 BPVC ids and 13
    # more had no year, so the editions of one document were identical.
    it "keeps the year of every identifier that prints one" do
      bad = AsmeIndexKeySpec.parsed_corpus.select do |line, id|
        line.match?(/-(\d{4}|20XX|202X)\b/) && id.year.nil? &&
          id.draft_year.nil?
      end
      expect(bad.map(&:first).first(5)).to eq([])
    end

    it "never stores the year inside the number" do
      bad = AsmeIndexKeySpec.parsed_corpus.select do |_, id|
        id.number.to_s.match?(/-\d{4}\z/)
      end
      expect(bad.map(&:first).first(5)).to eq([])
    end
  end

  # The Boiler and Pressure Vessel Code documents. Their whole identity is the
  # designator, so the builder assembles it from the parse tree; the three
  # defects below were all in that assembly.
  describe "BPVC documents" do
    {
      "ASME BPVC.I-2021" => ["BPVC.I", "2021"],
      "ASME BPVC.III.1.NB-2023" => ["BPVC.III.1.NB", "2023"],
      "ASME BPVC.VIII.1_ES-2013" => ["BPVC.VIII.1_ES", "2013"],
      "ASME BPVC COMPLETE CODE BIND-2019" =>
        ["BPVC COMPLETE CODE BIND", "2019"],
      "ASME BPVC.CC.BPV-2021" => ["BPVC.CC.BPV", "2021"],
      # The case sub-code kept its leading dot: "BPVC.CC.BPV..I".
      "ASME BPVC.CC.BPV.I-2019" => ["BPVC.CC.BPV.I", "2019"],
      "ASME BPVC.CC.NC.XI-2023" => ["BPVC.CC.NC.XI", "2023"],
      # The sections sit under `ssc_code` in the parse tree, and the builder
      # read them one level up: "BPVC.SSC.".
      "ASME BPVC.SSC.XI.II.V.IX-2021" => ["BPVC.SSC.XI.II.V.IX", "2021"],
      # The other SSC codes of the ASME catalogue (asme.org). Each names a
      # different document, by the BPVC sections it summarizes.
      "ASME BPVC.SSC.VIII.XII.II.V.IX-2021" =>
        ["BPVC.SSC.VIII.XII.II.V.IX", "2021"],
      "ASME BPVC.SSC.VIII.XII.II.V.IX.XIII-2023" =>
        ["BPVC.SSC.VIII.XII.II.V.IX.XIII", "2023"],
      "ASME BPVC.SSC.I.II.V.IX-2021" => ["BPVC.SSC.I.II.V.IX", "2021"],
      "ASME BPVC.SSC.I.II.V.IX.XIII-2023" => ["BPVC.SSC.I.II.V.IX.XIII", "2023"],
      "ASME BPVC.SSC.III.II.V.IX-2023" => ["BPVC.SSC.III.II.V.IX", "2023"],
      "ASME BPVC.SSC.IV.II.V.IX-2021" => ["BPVC.SSC.IV.II.V.IX", "2021"],
      "ASME BPVC.SSC.IV.II.V.IX.XIII-2023" =>
        ["BPVC.SSC.IV.II.V.IX.XIII", "2023"],
      "ASME BPVC.SSC.X.II.V-2021" => ["BPVC.SSC.X.II.V", "2021"],
      "ASME BPVC.SSC.X.II.V.XIII-2023" => ["BPVC.SSC.X.II.V.XIII", "2023"],
      "ASME BPVC-CC-BPV-2019" => ["BPVC-CC-BPV", "2019"],
      "ASME BPVC-CC-NUC-2019" => ["BPVC-CC-NUC", "2019"],
    }.each do |ref, (number, year)|
      it "parses #{ref}" do
        id = Pubid::Asme.parse(ref)
        expect([id.number, id.year]).to eq([number, year])
        expect(id.to_s).to eq("ASME #{number}-#{year}")
      end
    end

    it "tells the editions of one document apart" do
      editions = %w[2021 2023 2025].map do |year|
        Pubid::Asme.parse("ASME BPVC.CC.BPV-#{year}")
      end
      expect(editions.map(&:to_hash).uniq.size).to eq(3)
      expect(editions.map(&:to_mr_string).uniq.size).to eq(3)
      expect(editions.map(&:to_urn).uniq.size).to eq(3)
    end

    # The ASME catalogue lists BPVC-CC-BPV and BPVC.CC.BPV as two separate
    # documents, so the dash form is kept, not normalized to dots.
    it "keeps BPVC-CC-BPV and BPVC.CC.BPV apart" do
      dashed = Pubid::Asme.parse("ASME BPVC-CC-BPV-2019")
      dotted = Pubid::Asme.parse("ASME BPVC.CC.BPV-2021")
      expect(dashed.root.number).not_to eq(dotted.root.number)
      expect(dashed.exclude(:year)).not_to eq(dotted.exclude(:year))
    end

    # The slug is an output filename, so the two documents must not share it.
    # ASME sells both in 2019 (the main book and the 2019 supplements).
    it "gives BPVC-CC-BPV and BPVC.CC.BPV different slugs" do
      slugs = %w[BPVC-CC-BPV BPVC.CC.BPV].map do |code|
        Pubid::Asme.parse("ASME #{code}-2019").to_mr_string
      end
      expect(slugs).to eq(["asme.bpvc--cc--bpv.2019", "asme.bpvc-cc-bpv.2019"])
    end
  end

  describe "designators with no number" do
    {
      "ASME BPE-2012" => "BPE",
      "ASME OM-2017" => "OM",
      "ASME PASE-2019" => "PASE",
    }.each do |ref, number|
      it "keeps the year of #{ref} out of the number" do
        id = Pubid::Asme.parse(ref)
        expect([id.number, id.year]).to eq([number, ref[-4..]])
        expect(id.to_s).to eq(ref)
      end
    end

    it "still reads a dashed number (BTH-1)" do
      id = Pubid::Asme.parse("ASME BTH-1-2020")
      expect([id.number, id.year]).to eq(["BTH-1", "2020"])
    end
  end

  # The serialized code was a NESTED hash; it is now flat scalars, which is
  # what an index row wants. No relaton-data-asme exists, so nothing published
  # has to migrate.
  describe "serialized shape" do
    it "emits flat scalars instead of a nested code hash" do
      expect(Pubid::Asme.parse("ASME B18.3-2012").to_hash)
        .to eq(
          "_type" => "pubid:asme:standard",
          "publisher" => "ASME",
          "number" => "B18.3",
          "year" => "2012",
        )
    end
  end
end
