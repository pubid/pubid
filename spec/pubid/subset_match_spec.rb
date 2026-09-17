# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# `reference === candidate` is a SUBSET match: every part the reference states
# must match the candidate, and every part it leaves nil or empty is a
# wildcard. relaton uses it to match a partial user reference against index
# rows without a per-flavor `ignore:` list. The match walks the objects, so a
# flavor can give one attribute or one component its own rule
# (`subset_ignored_attributes`, `subset_attribute_match?`).
#
# One pair per registered flavor, keyed like `partial_ref_spec.rb`: the
# reference is the flavor's partial reference, and the candidate states more.
# A flavor whose identifier has no separable part uses the reference itself.
SUBSET_PAIRS = {
  "iso" => { ref: "ISO 9001", candidate: "ISO 9001:2015" },
  "iec" => { ref: "IEC 60601", candidate: "IEC 60601-1:2005" },
  "etsi" => { ref: "ETSI EN 300 175",
              candidate: "ETSI EN 300 175-1 V2.9.1 (2020-04)" },
  "nist" => { ref: "NIST SP 800-53", candidate: "NIST SP 800-53r5" },
  "ieee" => { ref: "IEEE 802.3", candidate: "IEEE 802.3-2018" },
  "itu" => { ref: "ITU-T G.711", candidate: "ITU-T G.711 (11/1988)" },
  "gost" => { ref: "ГОСТ 34.201", candidate: "ГОСТ 34.201-89" },
  "bsi" => { ref: "BS 5839", candidate: "BS 5839-1:2017" },
  "cen_cenelec" => { ref: "EN 13485", candidate: "EN 13485:2001" },
  "cen" => { ref: "EN 13485", candidate: "EN 13485:2001" },
  "calconnect" => { ref: "CC 11001", candidate: "CC 11001:2023" },
  "jcgm" => { ref: "JCGM 100", candidate: "JCGM 100:2008" },
  "bipm" => { ref: "CCTF REC 2", candidate: "CCTF REC 2 (2017)" },
  "csa" => { ref: "CSA Z299.1", candidate: "CSA Z299.1-78" },
  "ashrae" => { ref: "ASHRAE 15", candidate: "ASHRAE 15-2019" },
  "cie" => { ref: "CIE 015", candidate: "CIE 015:2018" },
  "idf" => { ref: "IDF 148-1", candidate: "IDF 148-1:2006" },
  "oiml" => { ref: "OIML V 1", candidate: "OIML V 1:2013" },
  "jis" => { ref: "JIS A 0001", candidate: "JIS A 0001:1999" },
  "ansi" => { ref: "ANSI C135.14", candidate: "ANSI C135.14-1979" },
  "asme" => { ref: "ASME B18.3", candidate: "ASME B18.3-2012" },
  "api" => { ref: "API 1509", candidate: "API 1509-2019" },
  "easc" => { ref: "ПМГ 126", candidate: "ПМГ 126-2015" },
  "astm" => { ref: "ASTM A6", candidate: "ASTM A6-19" },
  "iho" => { ref: "IHO P-5", candidate: "IHO P-5 2.0.0" },
  # OASIS keeps the verbatim slug in `original`, which the match ignores.
  "oasis" => { ref: "OASIS WSDM", candidate: "OASIS WSDM-v1.1" },
  "sae" => { ref: "SAE AIR1936", candidate: "SAE AIR1936:2020" },
  "3gpp" => { ref: "3GPP TS 23.207",
              candidate: "3GPP TS 23.207:Rel-6/6.6.0" },
  "w3c" => { ref: "W3C NOTE-xml-names",
             candidate: "W3C NOTE-xml-names-19980917" },
  "gb" => { ref: "GB/T 20223", candidate: "GB/T 20223-2006" },
  "omg" => { ref: "OMG UML", candidate: "OMG UML 2.5.1" },
  "evs" => { ref: "EVS-EN 18216", candidate: "EVS-EN 18216:2025" },
  "ecma" => { ref: "ECMA TR/18", candidate: "ECMA TR/18 ed3" },
  "adobe" => { ref: "Adobe TN 5014", candidate: "Adobe TN 5014" },
  "iana" => { ref: "IANA calipso", candidate: "IANA calipso" },
  "xsf" => { ref: "XEP 0001", candidate: "XEP 0001" },
  "ietf" => { ref: "STD 3", candidate: "STD 3" },
  "ccsds" => { ref: "CCSDS 121.0-B-1", candidate: "CCSDS 121.0-B-1" },
  "plateau" => { ref: "PLATEAU Technical Report #00",
                 candidate: "PLATEAU Technical Report #00" },
  "iala" => { ref: "S1070", candidate: "S1070" },
  "ogc" => { ref: "24-032r1", candidate: "24-032r1" },
  "amca" => { ref: "AMCA Publication 211-22",
              candidate: "AMCA Publication 211-22" },
  "un" => { ref: "TRADE/WP.4/1068", candidate: "TRADE/WP.4/1068" },
  "doi" => { ref: "doi:10.1000/182", candidate: "doi:10.1000/182" },
  "isbn" => { ref: "ISBN 978-3-16-148410-0",
              candidate: "ISBN 978-3-16-148410-0" },
}.freeze

# The corpus sweep reads at most this many ids per flavor, spread evenly.
SUBSET_MATCH_SAMPLE_PER_FLAVOR = 300
SUBSET_MATCH_FIXTURE_ROOT = File.expand_path("../fixtures", __dir__)

RSpec.describe "Pubid::Identifier#=== (subset match)" do
  def parse(flavor, string)
    Pubid::Registry.get(flavor).parse(string)
  end

  def rebuild(identifier)
    Pubid::Identifier.from_hash(identifier.to_hash)
  end

  it "has a subset pair for every registered flavor" do
    missing = Pubid::Registry.flavor_names - SUBSET_PAIRS.keys
    expect(missing).to be_empty,
                       "add a SUBSET_PAIRS entry for: #{missing.join(', ')}"
  end

  it "has no stale entry for an unregistered flavor" do
    stale = SUBSET_PAIRS.keys - Pubid::Registry.flavor_names
    expect(stale).to be_empty,
                     "remove stale SUBSET_PAIRS entry: #{stale.join(', ')}"
  end

  SUBSET_PAIRS.each do |flavor, pair|
    describe "#{flavor}: #{pair[:ref]} === #{pair[:candidate]}" do
      let(:ref) { parse(flavor, pair[:ref]) }
      let(:candidate) { parse(flavor, pair[:candidate]) }

      it "matches the candidate" do
        expect(ref === candidate).to be(true)
      end

      it "matches the candidate rebuilt from its hash (an index row)" do
        expect(ref === rebuild(candidate)).to be(true)
      end

      it "matches itself" do
        expect(ref === parse(flavor, pair[:ref])).to be(true)
      end

      if pair[:ref] != pair[:candidate]
        it "does not match in the reverse direction" do
          expect(candidate === ref).to be(false)
        end
      end
    end
  end

  describe "semantics" do
    def iso(string) = Pubid::Iso.parse(string)
    def bsi(string) = Pubid::Bsi.parse(string)

    it "matches an omitted year of the standard and of its amendment" do
      expect(iso("ISO 9001/Amd 1") === iso("ISO 9001:2015/Amd 1:2020"))
        .to be(true)
      expect(iso("ISO 9001:2015/Amd 1") === iso("ISO 9001:2015/Amd 1:2020"))
        .to be(true)
      expect(Pubid::CenCenelec.parse("EN 13250/A1") ===
             Pubid::CenCenelec.parse("EN 13250:2000/A1:2005")).to be(true)
    end

    it "matches the parts a BSI consolidated edition states" do
      candidate = bsi("BS 7273-4:2015+A1:2021")
      expect(bsi("BS 7273-4+A1") === candidate).to be(true)
      expect(bsi("BS 7273-4:2015+A1") === candidate).to be(true)
      expect(bsi("BS 7273-4:2015+A1:2021") === candidate).to be(true)
      expect(bsi("BS 7273-4+A2") === candidate).to be(false)
    end

    it "matches a BSI adoption whose hash cannot be built" do
      expect(bsi("BS EN 10077-1") === bsi("BS EN 10077-1:2006")).to be(true)
      expect(bsi("BS ISO 8601") === bsi("BS ISO 8601:2019")).to be(true)
    end

    it "does not fall back to the base document of a wrapper" do
      expect(bsi("BS 7273-4") === bsi("BS 7273-4:2015+A1:2021")).to be(false)
      expect(iso("ISO 9001") === iso("ISO 9001:2015/Amd 1:2020")).to be(false)
    end

    it "treats a stated part as a restriction" do
      expect(iso("ISO 9001-1") === iso("ISO 9001:2015")).to be(false)
      expect(iso("ISO 9001:2014") === iso("ISO 9001:2015")).to be(false)
    end

    # A default is a value, so it is stated: a bare reference means the
    # published document, not every stage of it.
    it "treats a default value as stated" do
      expect(iso("ISO 9001") === iso("ISO/DIS 9001")).to be(false)
      expect(iso("ISO 9001") === iso("ISO 9001 (all parts)")).to be(false)
      expect(Pubid::Iec.parse("IEC 60601") === Pubid::Iec.parse("IEC/CD 60601"))
        .to be(false)
    end

    it "compares collections by position, with a shorter reference" do
      expect(iso("ISO 9001") === iso("ISO/IEC 9001:2015")).to be(true)
      expect(iso("ISO/IEC 9001") === iso("ISO/IEC/IEEE 9001:2015")).to be(true)
      expect(iso("ISO/IEEE 9001") === iso("ISO/IEC/IEEE 9001:2015"))
        .to be(false)
      expect(iso("ISO 9001(en)") === iso("ISO 9001:2015(en,fr)")).to be(true)
      expect(iso("ISO 9001(fr)") === iso("ISO 9001:2015(en,fr)")).to be(false)
    end

    it "is false for a value that is not an identifier" do
      expect(iso("ISO 9001") === "ISO 9001:2015").to be(false)
      expect(iso("ISO 9001") === nil).to be(false)
    end

    it "is false for a different identifier class" do
      expect(iso("ISO 9001") === Pubid::Iec.parse("IEC 9001:2015")).to be(false)
    end

    it "leaves #== exact" do
      expect(iso("ISO 9001") == iso("ISO 9001:2015")).to be(false)
    end

    it "works as a case-equality pattern" do
      catalogue = ["ISO 9001:2008", "ISO 14001:2015", "ISO 9001:2015"]
        .map { |s| iso(s) }
      expect(catalogue.grep(iso("ISO 9001")).map(&:to_s))
        .to eq(["ISO 9001:2008", "ISO 9001:2015"])

      matched = case iso("ISO 9001:2015")
                when iso("ISO 14001") then :environment
                when iso("ISO 9001") then :quality
                end
      expect(matched).to eq(:quality)
    end
  end

  describe "components" do
    it "matches an omitted month and day of a date" do
      year = Pubid::Components::Date.new(year: "2015")
      full = Pubid::Components::Date.new(year: "2015", month: "04")
      expect(year === full).to be(true)
      expect(full === year).to be(false)
    end

    it "ignores the input spelling of a typed stage" do
      short = Pubid::Components::TypedStage.new(name: "Amendment",
                                                original_abbr: "Amd")
      upper = Pubid::Components::TypedStage.new(name: "Amendment",
                                                original_abbr: "AMD")
      expect(short === upper).to be(true)
    end
  end

  describe "flavor hooks" do
    it "declares no ignored attribute by default" do
      expect(Pubid::Identifier.subset_ignored_attributes).to eq([])
    end

    # NIST's build artifacts are not serialized, so an index row lacks them.
    it "ignores the NIST build artifacts" do
      id = Pubid::Nist.parse("NBS BH 1")
      row = rebuild(id)
      expect(id.first_number).not_to be_nil
      expect(row.first_number).to be_nil
      expect(id === row).to be(true)
      expect(row === id).to be(true)
    end

    # An ITU supplement copies sector/series/code from its base and does not
    # serialize the copies.
    it "ignores the base copies of an ITU supplement" do
      id = Pubid::Itu.parse("ITU-T G.711 (1988) Amd. 1 (09/1999)")
      expect(Pubid::Itu.parse("ITU-T G.711 Amd. 1") === rebuild(id)).to be(true)
      expect(id === rebuild(id)).to be(true)
    end

    # A format flag of an omitted year is at its default in a bare reference.
    it "skips the CSA year format flags when the reference has no year" do
      csa = ->(string) { Pubid::Csa.parse(string) }
      candidate = csa.call("CSA C22.2 NO. 125-M1984 (R2004)")
      expect(csa.call("CSA C22.2 NO. 125") === candidate).to be(true)
      expect(csa.call("CSA C22.2 NO. 125 (R2004)") === rebuild(candidate))
        .to be(true)
      expect(csa.call("CSA B149.1") === csa.call("CSA B149.1:F20")).to be(true)
    end

    it "skips the IEC/IEEE year separator when the reference has no year" do
      expect(Pubid::Ieee.parse("IEC/IEEE 60076-57-129") ===
             Pubid::Ieee.parse("IEC/IEEE 60076-57-129:2017")).to be(true)
    end

    it "ignores the verbatim OASIS slug" do
      expect(Pubid::Oasis.parse("OASIS WSDM-v1.0") ===
             Pubid::Oasis.parse("OASIS WSDM-v1.1")).to be(false)
    end
  end

  # Every component type that an identifier attribute can hold must include
  # the module, or `===` falls back to strict `==` for that part without a
  # signal. This is the forcing function for a new component class.
  it "is included by every component type an identifier attribute declares" do
    load_classes = lambda do |namespace, depth|
      return if depth > 2

      namespace.constants.each do |const|
        value = begin
          namespace.const_get(const)
        rescue StandardError, ScriptError
          next
        end
        load_classes.call(value, depth + 1) if value.is_a?(Module)
      end
    end
    Pubid::Registry.flavor_names.each do |flavor|
      load_classes.call(Pubid::Registry.get(flavor), 0)
    end

    identifier_classes = ObjectSpace.each_object(Class)
      .select { |klass| klass <= Pubid::Identifier }
    # A walk that stops early finds no offender and passes silently; the
    # annotated-rendering spec had that defect with IEEE's `Nesc::` classes.
    expect(identifier_classes.size).to be > 350
    types = identifier_classes.flat_map do |klass|
      klass.attributes.values.filter_map do |attr|
        attr.type
      rescue StandardError
        nil
      end
    end
    offenders = types.uniq.select do |type|
      type.is_a?(Class) && type < Lutaml::Model::Serializable &&
        !type.include?(Pubid::SubsetMatch)
    end

    expect(offenders.map(&:name)).to be_empty
  end

  # The relaton case: a parsed reference against a row rebuilt by from_hash.
  # Where the round trip keeps `==`, it must keep `===` in both directions, so
  # `===` adds no miss beyond the pre-existing `==` defects.
  describe "round trip over the fixture corpus" do
    include FixtureFileHelper

    flavors = Dir[File.join(SUBSET_MATCH_FIXTURE_ROOT, "*/identifiers/pass")]
      .map { |dir| dir.split("/")[-3] }
      .select { |flavor| Pubid::Registry.flavor_names.include?(flavor) }

    flavors.sort.each do |flavor|
      it "#{flavor}: every id whose round trip is == also matches with ===" do
        pattern = File.join(SUBSET_MATCH_FIXTURE_ROOT, flavor,
                            "identifiers/pass/*.txt")
        inputs = Dir[pattern]
          .flat_map { |f| read_pass_fixture_entries(f).map(&:first) }.uniq
        stride = [inputs.size / SUBSET_MATCH_SAMPLE_PER_FLAVOR, 1].max
        offenders = inputs.each_slice(stride).map(&:first).filter_map do |input|
          # Only the parse and the round trip may fail here; an error from
          # `===` itself must fail the example.
          id, row = begin
            parsed = parse(flavor, input)
            [parsed, rebuild(parsed)]
          rescue StandardError
            next
          end
          next unless (id == row rescue false) # rubocop:disable Style/RescueModifier
          next if id === row && row === id

          input
        end

        expect(offenders).to be_empty
      end
    end
  end
end
