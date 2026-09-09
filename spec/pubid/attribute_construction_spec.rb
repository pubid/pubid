# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# Cross-flavor contract for building an identifier from an attribute hash —
# the path the metanorma mapping layer uses, and the subject of pubid#360
# item 3.
#
# Three rules, locked here for every registered flavor:
#
#   unknown key      -> ArgumentError naming it (never silently dropped)
#   scalar edition   -> coerced to the declared component type
#   scalar year      -> folded into the `date` component
#
# Why the unknown-key rule is not cosmetic: `year` is NOT an attribute on a
# date-based flavor, it is a reader over `date` (identifier.rb). So the obvious
# `new(number: "1000", year: 2023)` used to return an identifier with no year
# at all and no diagnostic — the exact complaint in the issue. Dropping a key
# without a word is how that happens, so the key has to be refused.
#
# Registry-driven rather than table-driven, mirroring
# spec/pubid/parse_error_spec.rb: the bogus key below is unknown to every
# flavor, so there is no per-flavor entry to add — and none to go stale — when
# a flavor is added.
RSpec.describe "attribute construction contract (cross-flavor)" do
  # A key no flavor declares. Deliberately not a near-miss of a real attribute.
  BOGUS_KEY = :definitely_not_a_pubid_attribute

  it "covers every registered flavor" do
    expect(Pubid::Registry.flavor_names).not_to be_empty
    expect(Pubid::Registry.flavor_names).to include("iso", "iec", "3gpp", "w3c")
  end

  describe "unknown keys" do
    Pubid::Registry.flavor_names.each do |flavor_name|
      context flavor_name do
        let(:identifier_class) do
          Pubid::Registry.get(flavor_name).const_get(:Identifier)
        end

        it "raises ArgumentError naming the key" do
          expect { identifier_class.new(BOGUS_KEY => 1) }
            .to raise_error(ArgumentError, /#{BOGUS_KEY}/),
                "#{flavor_name} accepted an unknown key silently"
        end

        it "still accepts a declared attribute" do
          expect { identifier_class.new(number: "1") }.not_to raise_error
        end

        # lutaml reads this out of the attribute hash itself
        # (Serializable#extract_register_id), so it is reserved, not unknown.
        it "accepts the reserved :lutaml_register key" do
          expect { identifier_class.new(lutaml_register: :default) }
            .not_to raise_error
        end
      end
    end
  end

  # The two paths that rebuild an identifier from its own attributes must keep
  # working — they are what would break if the check were applied too widely.
  # `#exclude` rebuilds through `self.class.new(**attrs)`; `from_hash` assigns
  # through setters after an argument-less `new`.
  describe "internal rebuild paths are unaffected" do
    {
      "iso" => "ISO 1234-1:2013",
      "iec" => "IEC 60038:2009",
      "ieee" => "IEEE Std 802.11-2020",
      "itu" => "ITU-T G.711",
      "nist" => "NIST SP 800-53",
      "bsi" => "BS 5555:1981",
    }.each do |flavor_name, ref|
      it "#{flavor_name}: exclude and from_hash still round-trip #{ref}" do
        id = Pubid::Registry.get(flavor_name).parse(ref)

        expect { id.exclude(:year) }.not_to raise_error
        expect { id.class.from_hash(id.to_hash) }.not_to raise_error
      end
    end
  end

  # A builder constructs identifiers through the same public constructor, so
  # the refusal reaches internal callers too — and it found one. CIE's builder
  # assembled a single attribute hash for every CIE type and always set
  # `s_prefix`, which only Standard, DualPublished and Identical declare;
  # lutaml dropped it for the rest without a word. Once the constructor refused
  # it, 94 CIE identifiers stopped parsing. The builder now offers each class
  # only the attributes it declares.
  describe "builders offer only declared attributes" do
    {
      "a conference paper" => "CIE x005-1992",
      "a comma-list bundle" => "CIE 198-SP1.1:2011,198-SP1.2:2011",
      "a standard that DOES declare s_prefix" => "CIE S 017/E:2020",
    }.each do |label, ref|
      it "parses #{label} (#{ref})" do
        expect { Pubid::Cie.parse(ref) }.not_to raise_error
        expect(Pubid::Cie.parse(ref).to_s).to eq(ref)
      end
    end

    it "keeps s_prefix on the types that declare it" do
      expect(Pubid::Cie.parse("CIE S 017/E:2020").s_prefix).to be(true)
    end

    it "does not give s_prefix to a type that does not declare it" do
      expect(Pubid::Cie::Identifiers::Conference.attributes)
        .not_to have_key(:s_prefix)
    end
  end

  describe "scalar coercion" do
    # A flavor whose `edition` is declared as a component: the scalar is
    # wrapped, so `edition.number` works and `to_hash` does not raise.
    it "wraps a scalar edition in the declared component (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      from_scalar = klass.new(number: "1000", edition: 2)
      from_component = klass.new(
        number: "1000",
        edition: Pubid::Components::Edition.new(number: "2"),
      )

      expect(from_scalar.edition).to be_a(Pubid::Components::Edition)
      expect(from_scalar.edition.number.to_s).to eq("2")
      expect(from_scalar.to_s).to eq(from_component.to_s)
      expect(from_scalar.to_hash).to eq(from_component.to_hash)
    end

    it "accepts a String edition as readily as an Integer (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      expect(klass.new(number: "1000", edition: "2").to_s)
        .to eq(klass.new(number: "1000", edition: 2).to_s)
    end

    # A flavor that declares `edition` as a plain :string must NOT be wrapped —
    # the coercion is type-aware, not blanket.
    it "leaves a scalar edition alone when the flavor declares a string (ECMA)" do
      id = Pubid::Ecma::Identifiers::Standard.new(number: "434", edition: "1")

      expect(id.edition).to eq("1")
    end

    it "folds a scalar year into the date component (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      id = klass.new(number: "1000", year: 2023)

      expect(id.date).to be_a(Pubid::Components::Date)
      expect(id.year).to eq("2023")
      expect(id.to_s).to eq("IEC 1000:2023")
    end

    it "folds year, month and day together (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      id = klass.new(number: "1000", year: 2025, month: 10)

      expect(id.date.year).to eq("2025")
      expect(id.date.month).to eq("10")
    end

    # ~20 flavors declare a real `year` attribute. Folding there would destroy
    # the attribute, so the fold must only fire when `year` is not declared.
    it "leaves a declared year attribute alone (GOST)" do
      id = Pubid::Gost::Identifiers::InterstateStandard.new(
        number: "25346", year: "2013",
      )

      expect(id.year).to eq("2013")
    end

    # A COMPONENT-TYPED COLLECTION was the residue of item 3. lutaml casts a
    # Hash element into the component but passes a String through untouched, so
    # `languages: ["en"]` stored raw Strings and then raised — in the renderer
    # (`wrong number of arguments`, iec/single_identifier.rb) and in the URN
    # generator (`undefined method 'code'`). Every shape must agree.
    it "wraps a scalar language inside a collection (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      id = klass.new(number: "1000", part: "1", year: 2023, edition: 2,
                     languages: ["en"])

      expect(id.languages).to all(be_a(Pubid::Components::Language))
      expect(id.to_s).to eq("IEC 1000-1:2023 ED2(en)")
      expect(id.to_urn).to eq("urn:iec:std:iec:1000-1:2023::ed-2:en")
    end

    it "gives the scalar, Hash and component forms one result (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard
      args = { number: "1000", year: 2023 }

      from_scalar = klass.new(**args, languages: ["en"])
      from_hash = klass.new(**args, languages: [{ code: "en" }])
      from_component = klass.new(
        **args, languages: [Pubid::Components::Language.new(code: "en")],
      )

      expect(from_hash.to_s).to eq(from_scalar.to_s)
      expect(from_component.to_s).to eq(from_scalar.to_s)
      expect(from_hash.to_hash).to eq(from_scalar.to_hash)
      expect(from_component.to_hash).to eq(from_scalar.to_hash)
    end

    # Publisher is the second degenerate component, and it raised the same way
    # (`undefined method 'body'`). The `<=` match is what admits the flavor
    # subclass Pubid::Iec::Components::Publisher.
    it "wraps a scalar copublisher in the subclass (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      id = klass.new(number: "1000", copublishers: ["ISO"])

      expect(id.copublishers).to all(be_a(Pubid::Iec::Components::Publisher))
      expect(id.to_s).to eq("IEC/ISO 1000")
    end

    # The coercion is type-aware here too: ~8 flavors declare `language` as a
    # plain :string and must keep the scalar they were given.
    it "leaves a scalar language alone when declared a string (ASME)" do
      id = Pubid::Asme::Identifiers::Standard.new(
        number: "B31.1", language: "SPANISH",
      )

      expect(id.language).to eq("SPANISH")
    end

    # Components::Code is deliberately NOT coerced. A String in `number`
    # renders and serializes correctly, and wrapping it would turn `to_hash`
    # into {"number" => {"value" => "9001"}} on the five flavors that still
    # declare a Code — an index wire-format change. This pins the exclusion, so
    # a later branch that widens DEGENERATE_COMPONENT_FIELDS has to say why.
    it "leaves a scalar number uncoerced (ISO)" do
      id = Pubid::Iso::Identifiers::InternationalStandard.new(number: "9001")

      expect(id.number).to be_a(String)
      expect(id.to_hash["number"]).to eq("9001")
    end

    # IEC's number is a plain :string attribute now, so a String is not merely
    # tolerated — it is the type. That is what makes the two construction paths
    # `==`, which the to_s/to_hash assertions below cannot see: both were
    # already equal while a Code from `parse` and a String from `new` made the
    # identifiers silently unequal. See spec/pubid/iec/number_string_spec.rb.
    it "declares a scalar number outright (IEC)" do
      id = Pubid::Iec::Identifiers::InternationalStandard.new(number: "1000")

      expect(Pubid::Iec::Identifier.attributes[:number].type)
        .to eq(Lutaml::Model::Type::String)
      expect(id.number).to be_a(String)
      expect(id.to_hash["number"]).to eq("1000")
    end

    it "matches the parsed identifier exactly (IEC)" do
      klass = Pubid::Iec::Identifiers::InternationalStandard

      built = klass.new(number: "60038", year: 2009, edition: 2)
      parsed = Pubid::Iec.parse("IEC 60038:2009 ED2")

      expect(built.to_s).to eq(parsed.to_s)
      expect(built.to_hash).to eq(parsed.to_hash)
      expect(built).to eq(parsed)
    end
  end

  # Registry-driven, like the unknown-key block above: a String must never
  # survive into a component-typed `languages` on ANY flavor, so a flavor added
  # tomorrow is covered without an entry to add here.
  describe "degenerate component coercion (cross-flavor)" do
    Pubid::Registry.flavor_names.each do |flavor_name|
      context flavor_name do
        let(:identifier_class) do
          Pubid::Registry.get(flavor_name).const_get(:Identifier)
        end

        it "never leaves a String in a component-typed languages" do
          attribute = identifier_class.attributes[:languages]
          skip "does not declare languages as a component" unless
            attribute&.type.is_a?(Class) &&
              attribute.type <= Pubid::Components::Language

          id = identifier_class.new(languages: ["en"])

          expect(id.languages).to all(be_a(Pubid::Components::Language)),
                                  "#{flavor_name} kept a raw String"
        end
      end
    end
  end
end
