# frozen_string_literal: true

require "spec_helper"

# Structural tripwire for the OMG `part` retype.
#
# ::Pubid::Identifier declares `part` as a Pubid::Components::Code. An OMG
# document part is a volume or format NAME ("Superstructure", "PDF"), not a
# numbered part, so Pubid::Omg::Identifier redeclares it as a plain :string —
# the tranche-1 shape recorded in CLAUDE.md for ansi/api/idf/jcgm/bsi/
# cen_cenelec.
#
# A redeclaration on a class that others inherit from is the multi-flavor
# determinism landmine CLAUDE.md records a dozen times. It is safe HERE only
# because Pubid::Omg::Identifier's class body lives in one file
# (lib/pubid/omg/identifier.rb) and is never reopened, so Ruby resolves the
# superclass to completion before Identifiers::Specification opens. This file
# is what catches a later edit that breaks that condition — by splitting the
# base across files, or by redeclaring `part` on a subclass, which would also
# move the generated accessor's owner.
#
# IMPORTANT: this is only meaningful under the FULL suite (`bundle exec rake`),
# never `rspec spec/pubid/omg` alone. lutaml deep-dups the parent attribute
# table into each subclass at class-definition time, so a single-flavor run can
# resolve the attribute differently from a run that has loaded every flavor.
module OmgPartStringSpec
  STRING = Lutaml::Model::Type::String
  # The base declares all three as :string since the retype landed, so the
  # "untouched" attributes resolve to the same String as `part`.
  CODE = Lutaml::Model::Type::String

  # OMG retypes `part` ALONE. `number` and `subpart` are untouched, and the
  # base declaration of all three is deliberately not changed until the last
  # tranche of the retype sequence — so this file pins the disagreement, which
  # is exactly what makes the landmine reachable.
  RETYPED = :part
  UNTOUCHED = %i[number subpart].freeze

  class << self
    # Every class in the OMG hierarchy, the shared base included. Reading
    # polymorphic_type_map first forces the concrete Identifiers::* classes to
    # autoload.
    def hierarchy
      base = Pubid::Omg::Identifier
      base.polymorphic_type_map
      ([base] + ObjectSpace.each_object(Class).select { |c| c < base })
        .uniq.sort_by(&:name)
    end
  end
end

RSpec.describe "Pubid::Omg `part` retype" do
  describe "structural tripwire (full-suite only)" do
    it "resolves `part` to a String on every class in the hierarchy" do
      offenders = OmgPartStringSpec.hierarchy.filter_map do |klass|
        type = klass.attributes[OmgPartStringSpec::RETYPED]&.type
        "#{klass.name}#part=#{type}" if type != OmgPartStringSpec::STRING
      end

      expect(offenders).to be_empty
    end

    # A redeclaration on a subclass is a no-op for type resolution once the
    # base agrees, but it moves the accessor's owner — the difference other
    # flavors' tripwires use to tell a lutaml accessor from a hand-written
    # delegation. Keep the single declaration on the base.
    it "declares `part` once, on Pubid::Omg::Identifier" do
      OmgPartStringSpec.hierarchy.each do |klass|
        expect(klass.instance_method(:part).owner)
          .to eq(Pubid::Omg::Identifier)
      end
    end

    it "leaves `number` and `subpart` as the inherited String" do
      OmgPartStringSpec::UNTOUCHED.each do |attr|
        expect(Pubid::Omg::Identifier.attributes[attr].type)
          .to eq(OmgPartStringSpec::CODE)
      end
    end
  end

  # The retype is only worth its risk if the scalar survives every path an
  # identifier travels. A Code would come back as a Hash from to_hash, and
  # #exclude rebuilds through self.class.new(**attrs).
  describe "the scalar survives every path" do
    subject(:parsed) do
      Pubid::Omg::Identifier.parse("OMG UML 2.1.1 Superstructure")
    end

    it "holds a String after parse" do
      expect(parsed.part).to be_a(String)
    end

    it "holds a String after from_hash" do
      rebuilt = Pubid::Omg::Identifier.from_hash(parsed.to_hash)

      expect(rebuilt.part).to be_a(String)
    end

    it "holds a String after a rebuild through #exclude" do
      expect(parsed.exclude(:version).part).to be_a(String)
    end

    it "serializes as a bare scalar, not a nested Code hash" do
      expect(parsed.to_hash["part"]).to eq("Superstructure")
    end
  end
end
