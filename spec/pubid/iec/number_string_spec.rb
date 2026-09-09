# frozen_string_literal: true

require "spec_helper"

# IEC holds `number`, `part` and `subpart` as plain `:string` attributes, not a
# `Pubid::Iec::Components::Code`.
#
# WHY THE COMPONENT WENT. `Iec::Components::Code` subclassed the shared Code for
# one reason: a `to_s` that prints `"#{prefix} #{value}"`. Measured over all
# 12,331 parseable IEC pass fixtures, `number`/`part`/`subpart` were a Code
# 9,975 / 5,422 / 2,416 times and NOT ONE populated `prefix`, `parts`, `part` or
# `subpart` inside it. The prefix branch was unreachable: `Code.parse` was the
# only site that ever passed `prefix:`, and it had zero callers, as did the
# `full_code` alias. Every IEC consumer already read the three through `to_s` or
# interpolation — never `.value`, `.render`, `.prefix` or `.parts`.
#
# WHY IT WAS A DEFECT, not just clutter. The parse path produced a Code while
# the CONSTRUCTOR path produced a String (a `:string` value assigned to a
# Code-typed attribute stayed a String), so a hand-built identifier and the
# parsed one were not `==` — and `#matches?` is
# `exclude(*ignore) == other.exclude(*ignore)`, so every matching call between
# them returned false. `to_s`, `to_urn` and `to_hash` were all correct on both
# sides, which is why nothing caught it: a relaton index lookup simply returned
# nothing, with no error. That is the failure mode the first block below pins.
#
# IMPORTANT: the structural block is only meaningful under the FULL suite
# (`bundle exec rake`), never `rspec spec/pubid/iec` alone. lutaml deep-dups the
# parent attribute table into each subclass at class-definition time, so a
# single-flavor run can resolve an attribute differently from a run that has
# loaded every flavor.
RSpec.describe "IEC number/part/subpart as :string" do
  let(:ref) { "IEC 60068-2-28:2008" }

  describe "the attributes" do
    # Every IEC class, the shared base included. Reading polymorphic_type_map
    # first forces the concrete Identifiers::* classes to autoload; ObjectSpace
    # then also picks up the intermediates they inherit (SingleIdentifier,
    # SupplementIdentifier, Identifiers::Base), which is where the
    # multi-flavor attribute-resolution landmine actually lives.
    def hierarchy
      base = Pubid::Iec::Identifier
      base.polymorphic_type_map
      ([base] + ObjectSpace.each_object(Class).select { |c| c < base })
        .uniq.sort_by(&:name)
    end

    %i[number part subpart].each do |attr|
      it "resolves #{attr} to String on every IEC class" do
        offenders = hierarchy.filter_map do |klass|
          type = klass.attributes[attr]&.type
          "#{klass.name}##{attr}=#{type}" if type != Lutaml::Model::Type::String
        end

        expect(offenders).to eq([])
      end
    end
  end

  describe "the parse path and the constructor path agree" do
    # The bug this branch removes. Both sides rendered and serialized
    # identically; only `==` (and therefore `#matches?`) saw the difference.
    let(:parsed) { Pubid::Iec.parse(ref) }
    let(:built) do
      Pubid::Iec::Identifiers::InternationalStandard.new(
        number: "60068", part: "2", subpart: "28", year: "2008",
      )
    end

    it "holds a String in number/part/subpart on both paths" do
      expect([parsed.number, parsed.part, parsed.subpart]).to all(be_a(String))
      expect([built.number, built.part, built.subpart]).to all(be_a(String))
    end

    it "renders the same" do
      expect(built.to_s).to eq(parsed.to_s)
    end

    it "is ==" do
      expect(built).to eq(parsed)
    end

    it "matches?" do
      expect(parsed.matches?(built)).to be true
    end

    it "matches? a part-less reference under ignore: [:part, :subpart]" do
      partial = Pubid::Iec.parse("IEC 60068")

      expect(partial.matches?(parsed, ignore: %i[part subpart date])).to be true
    end
  end

  describe "the serialized shape does not move" do
    # to_hash already emitted bare scalars through the old converters, so this
    # is a runtime-model change only and no relaton-data-iec row changes.
    it "emits bare scalars" do
      hash = Pubid::Iec.parse(ref).to_hash

      expect(hash["number"]).to eq("60068")
      expect(hash["part"]).to eq("2")
      expect(hash["subpart"]).to eq("28")
    end

    it "round-trips through from_hash" do
      id = Pubid::Iec.parse(ref)
      hash = id.to_hash

      expect(Pubid::Iec::Identifier.from_hash(hash).to_hash).to eq(hash)
      expect(Pubid::Iec::Identifier.from_hash(hash)).to eq(id)
    end
  end

  describe "the wrapper types still serialize their number once" do
    # number/part/subpart are mapped on SingleIdentifier, not on Identifier,
    # precisely so the four wrappers — which inherit from Identifier directly
    # and DELEGATE the reader to what they wrap — do not emit the delegated
    # value at the top level as well as inside "base"/"identifiers".
    {
      "CISPR 11:1975+AMD1:1976 CSV" => Pubid::Iec::Identifiers::VapIdentifier,
      "IEC 60695-2-1/0:1994" => Pubid::Iec::Identifiers::SheetIdentifier,
      "IEC 60050-111/AMD1/FRAG1 ED2" =>
        Pubid::Iec::Identifiers::FragmentIdentifier,
      "IEC 60050-300:2001+AMD1:2005" =>
        Pubid::Iec::Identifiers::ConsolidatedIdentifier,
    }.each do |input, klass|
      context "#{klass.name.split('::').last} (#{input})" do
        let(:id) { Pubid::Iec.parse(input) }

        it "parses to #{klass}" do
          expect(id).to be_a(klass)
        end

        it "omits the delegated number/part/subpart at the top level" do
          hash = id.to_hash

          expect(hash.keys & %w[number part subpart]).to eq([])
        end

        it "still reaches the number through #root, for the index key" do
          expect(id.root.number.to_s).not_to be_empty
        end
      end
    end
  end

  # Moving the maps onto SingleIdentifier makes "number" arrive AFTER the keys
  # of the parent block, and SupplementIdentifier#base_from_kv calls
  # mark_synthetic_standalone!, which reads @number. If from_hash walked the
  # INPUT hash's key order rather than the declared rule order, a hand-authored
  # hash listing "base" before "number" would reconstruct a standalone
  # supplement with the wrong supplement number — and silently, since nothing
  # raises. It does not: these assert the reconstruction is order-independent.
  describe "from_hash does not depend on the input hash's key order" do
    %w[
      IEC/FDAM\ 60038-1
      IEC\ 60038-1/AMD1:2005
      IEC\ 60038:2009/COR1:2010
    ].each do |input|
      context input do
        let(:hash) { Pubid::Iec.parse(input).to_hash }
        # "base" hoisted in front of every other key.
        let(:base_first) do
          { "_type" => hash["_type"], "base" => hash["base"] }
            .merge(hash.except("_type", "base"))
        end

        it "puts number before base in its own output" do
          expect(hash.keys.index("number")).to be < hash.keys.index("base")
        end

        it "reconstructs the same identifier from either order" do
          expect(Pubid::Iec::Identifier.from_hash(base_first))
            .to eq(Pubid::Iec::Identifier.from_hash(hash))
        end

        it "renders the same from either order" do
          expect(Pubid::Iec::Identifier.from_hash(base_first).to_s)
            .to eq(Pubid::Iec::Identifier.from_hash(hash).to_s)
        end
      end
    end
  end

  describe "the dead component is gone" do
    it "no longer defines Pubid::Iec::Components::Code" do
      expect(Pubid::Iec::Components.const_defined?(:Code, false)).to be false
    end
  end
end
