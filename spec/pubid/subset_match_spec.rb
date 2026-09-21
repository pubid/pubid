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
  # ETSI states its parts, so the reference carries the part too; the
  # version and the date are what it omits.
  "etsi" => { ref: "ETSI EN 300 175-1",
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

  # Force-load every class two levels inside each flavor namespace.
  # `eager_load_flavors!` only reaches the top-level module, so a class that
  # no example instantiates -- six of OIML's seven `CodeNumber` leaves --
  # is otherwise absent from ObjectSpace and a walk over it passes silently.
  def force_load_flavor_classes
    Pubid::Registry.flavor_names.each do |flavor|
      load_namespace(Pubid::Registry.get(flavor), 0)
    end
    ObjectSpace.each_object(Class)
      .select { |klass| klass <= Pubid::Identifier }
  end

  def load_namespace(namespace, depth)
    return if depth > 2

    namespace.constants.each do |const|
      value = begin
        namespace.const_get(const)
      rescue StandardError, ScriptError
        next
      end
      load_namespace(value, depth + 1) if value.is_a?(Module)
    end
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

  # A strict attribute is one the reference always states. A nil value means
  # "this document has none", not "any value", and a stated collection is not
  # a prefix. Without it `===` widens and the wrong record wins: relaton
  # measured 5 spurious part rows for `ECMA-418`, two broken 3GPP specs, and
  # 122 changed `best_match` winners for ETSI.
  describe "strict attributes" do
    def cen(string) = Pubid::CenCenelec.parse(string)

    it "declares none by default" do
      expect(Pubid::Identifier.subset_strict_attributes).to eq([])
    end

    it "is inherited by a subclass" do
      expect(Pubid::Ecma::Identifier.subset_strict_attributes).to include(:part)
      expect(Pubid::Ecma::Identifiers::Standard.subset_strict_attributes)
        .to include(:part)
    end

    it "ECMA: a nil part means no part" do
      expect(parse("ecma", "ECMA-418") === parse("ecma", "ECMA-418-1 ed1"))
        .to be(false)
      expect(parse("ecma", "ECMA-418-1") === parse("ecma", "ECMA-418-1 ed1"))
        .to be(true)
    end

    it "3GPP: a nil suffix and an empty part list mean none" do
      expect(parse("3gpp", "3GPP TS 29.198") ===
             parse("3gpp", "3GPP TS 29.198-04-1")).to be(false)
      expect(parse("3gpp", "3GPP TR 00.01") === parse("3gpp", "3GPP TR 00.01U"))
        .to be(false)
      exact = parse("3gpp", "3GPP TS 29.198-04-1")
      expect(exact === parse("3gpp", "3GPP TS 29.198-04-1")).to be(true)
    end

    it "ETSI: a stated part list is not a prefix" do
      expect(parse("etsi", "ETSI TS 129 198-4") ===
             parse("etsi", "ETSI TS 129 198-4-5")).to be(false)
      exact = parse("etsi", "ETSI TS 129 198-4")
      expect(exact === parse("etsi", "ETSI TS 129 198-4")).to be(true)
      expect(parse("etsi", "ETSI EN 300 175") ===
             parse("etsi", "ETSI EN 300 175-1")).to be(false)
    end

    it "CalConnect: a nil series means no series" do
      expect(parse("calconnect", "CC 36010") ===
             parse("calconnect", "CC/WD 36010:2019")).to be(false)
      expect(parse("calconnect", "CC/WD 36010") ===
             parse("calconnect", "CC/WD 36010:2019")).to be(true)
    end

    it "GOST: a nil copublisher means none" do
      expect(parse("gost", "ГОСТ Р 27001") ===
             parse("gost", "ГОСТ Р ИСО/МЭК 27001-2006")).to be(false)
      expect(parse("gost", "ГОСТ Р ИСО/МЭК 27001") ===
             parse("gost", "ГОСТ Р ИСО/МЭК 27001-2006")).to be(true)
    end

    it "PLATEAU: a nil annex means no annex" do
      expect(parse("plateau", "PLATEAU Handbook #10") ===
             parse("plateau", "PLATEAU Handbook #10-1 第1.0版")).to be(false)
      expect(parse("plateau", "PLATEAU Handbook #10-1") ===
             parse("plateau", "PLATEAU Handbook #10-1 第1.0版")).to be(true)
    end

    it "OIML: a nil suffix means none" do
      expect(parse("oiml", "OIML R 138") ===
             parse("oiml", "OIML R 138-Amend:2009")).to be(false)
      expect(parse("oiml", "OIML R 138-Amend") ===
             parse("oiml", "OIML R 138-Amend:2009")).to be(true)
    end

    it "CCSDS: a nil language means none" do
      expect(parse("ccsds", "CCSDS 650.0-M-2") ===
             parse("ccsds", "CCSDS 650.0-M-2 - French Translated")).to be(false)
      french = parse("ccsds", "CCSDS 650.0-M-2 - French Translated")
      expect(french === parse("ccsds", "CCSDS 650.0-M-2 - French Translated"))
        .to be(true)
    end

    it "CCSDS: a nil suffix means the current document, not the -S one" do
      current = parse("ccsds", "CCSDS 101.0-B-4")
      historical = parse("ccsds", "CCSDS 101.0-B-4-S")
      expect(current === historical).to be(false)
      expect(historical === current).to be(false)
      expect(historical === parse("ccsds", "CCSDS 101.0-B-4-S")).to be(true)
    end

    # A strict attribute that holds a component keeps that component's own
    # rule: `Components::TypedStage` ignores `original_abbr`, the input
    # spelling, and CEN declares `typed_stage` strict. A plain `==` here
    # would compare the spelling as if it were identity.
    it "composes with a nested component's own rule" do
      short = Pubid::Components::TypedStage.new(name: "Amendment",
                                                original_abbr: "Amd")
      upper = Pubid::Components::TypedStage.new(name: "Amendment",
                                                original_abbr: "AMD")
      other = Pubid::Components::TypedStage.new(name: "Corrigendum")

      expect(Pubid::SubsetMatch.exact_match?(short, upper)).to be(true)
      expect(Pubid::SubsetMatch.exact_match?(short, other)).to be(false)
      expect(Pubid::SubsetMatch.exact_match?(short, nil)).to be(false)
      expect(Pubid::SubsetMatch.exact_match?(nil, short)).to be(false)
    end

    # Exactness reaches into a collection too: a strict list matches in
    # full, element by element, never as a prefix.
    it "compares a strict collection in full" do
      expect(Pubid::SubsetMatch.exact_match?(%w[4], %w[4 5])).to be(false)
      expect(Pubid::SubsetMatch.exact_match?(%w[4 5], %w[4])).to be(false)
      expect(Pubid::SubsetMatch.exact_match?(%w[4 5], %w[4 5])).to be(true)
      expect(Pubid::SubsetMatch.exact_match?([], nil)).to be(true)
    end

    # A published CEN norm holds no type, stage or typed stage, so a nil one
    # means "published", not "any stage".
    it "CEN: a published norm is not a draft" do
      expect(cen("EN 1325") === cen("prEN 1325")).to be(false)
      expect(cen("EN 1325") === cen("EN 1325:2001")).to be(true)
      draft = cen("prEN 1325")
      expect(draft === cen("prEN 1325")).to be(true)
      expect(cen("EN 1991") === cen("ENV 1991-2-2")).to be(false)
    end

    # A name that is not an attribute of the class would be silently
    # ignored, so the walk has to see every class that declares one.
    it "names only attributes the class declares" do
      identifier_classes = force_load_flavor_classes
      # A walk that stops early finds no offender and passes silently.
      expect(identifier_classes.size).to be > 350

      declaring = ObjectSpace.each_object(Class).select do |klass|
        klass.respond_to?(:subset_strict_attributes) &&
          klass.respond_to?(:attributes) &&
          klass.subset_strict_attributes.any?
      end
      # The nine flavors of the table above, their subclasses and the two
      # components; well past OIML's seven leaves on their own.
      expect(declaring.size).to be > 20

      offenders = declaring.filter_map do |klass|
        undeclared = klass.subset_strict_attributes - klass.attributes.keys
        "#{klass.name}: #{undeclared.join(', ')}" if undeclared.any?
      end

      expect(offenders).to be_empty
    end
  end

  # Once a nil part means "none", `all_parts` is how a reference asks for the
  # whole collection without a `matches?(ignore:)` list. `#includes?` and
  # `Jis::Identifier#==` already read the flag this way.
  describe "all_parts as the part wildcard" do
    def iso(string) = Pubid::Iso.parse(string)

    it "matches every part of the document" do
      expect(iso("ISO 9001 (all parts)") === iso("ISO 9001-1:2015")).to be(true)
      expect(iso("ISO 9001 (all parts)") === iso("ISO 9001:2015")).to be(true)
    end

    it "reopens a strict part list" do
      reference = parse("etsi", "ETSI EN 300 175")
      expect(reference === parse("etsi", "ETSI EN 300 175-1")).to be(false)
      expect(reference.to_all_parts === parse("etsi", "ETSI EN 300 175-1"))
        .to be(true)
    end

    it "restricts every other part of the identifier" do
      expect(iso("ISO 9001 (all parts)") === iso("ISO 14001-1:2015"))
        .to be(false)
      expect(iso("ISO 9001 (all parts)") === iso("ISO/DIS 9001-1")).to be(false)
    end

    it "stays stated in the other direction" do
      expect(iso("ISO 9001") === iso("ISO 9001 (all parts)")).to be(false)
    end

    # A component never holds a document's parts, so the rule is on the
    # identifier alone.
    it "is an identifier rule, not a component rule" do
      component = Pubid::Components::Date.new(year: "2015")
      expect(Pubid::SubsetMatch.instance_method(:subset_all_parts_wildcard?)
        .bind_call(component)).to be(false)
    end
  end

  # Every component type that an identifier attribute can hold must include
  # the module, or `===` falls back to strict `==` for that part without a
  # signal. This is the forcing function for a new component class.
  it "is included by every component type an identifier attribute declares" do
    identifier_classes = force_load_flavor_classes
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
