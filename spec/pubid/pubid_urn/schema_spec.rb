# frozen_string_literal: true

require "spec_helper"

# The kinds of an atom and of a facet (docs/URN-SCHEMES.adoc, "Kinds").
RSpec.describe "pubid URN kinds" do
  describe Pubid::PubidUrn::FlavorSchema do
    def schema(&)
      Pubid::PubidUrn.define("x", &)
    end

    it "reads a path with * as a list of Strings by default" do
      s = schema { type "pubid:x:a", "a", atoms: [%w[parts.*.code part]] }
      atom = s.for_token("a").atoms.first
      expect([atom.kind, atom.list?, atom.element])
        .to eq([:list, true, :string])
    end

    it "takes :bools for a list of booleans" do
      s = schema { atom "rows.*.flag", "flag", kind: :bools }
      s.type "pubid:x:a", "a"
      atom = s.for_token("a").atoms.first
      expect([atom.list?, atom.element]).to eq([true, :bool])
    end

    it "gives a facet a kind" do
      s = schema { facet "spaced", "spaced", kind: :bool }
      s.type "pubid:x:a", "a"
      facet = s.for_token("a").facet("spaced")
      expect([facet.kind, facet.list?, facet.element])
        .to eq([:bool, false, :bool])
    end

    it "refuses a scalar kind on a path with *" do
      expect { schema { atom "rows.*.flag", "flag", kind: :bool } }
        .to raise_error(ArgumentError, /reads a list/)
      expect { schema { facet "rows.*.flag", "flag", kind: :string } }
        .to raise_error(ArgumentError, /reads a list/)
    end

    it "refuses a kind a facet cannot have" do
      expect { schema { facet "base", "b", kind: :id } }
        .to raise_error(ArgumentError, /unknown facet kind/)
    end
  end

  # The boolean kinds through the real codec, on ITU: a joint
  # Recommendation whose second designation prints its "bis" spaced.
  describe "boolean facets" do
    let(:id) { Pubid::Itu.parse("ITU-T D.81/F.80 bis (11/1980)") }
    let(:urn) { id.to_pubid_urn }

    it "writes a list of booleans and reads it back" do
      expect(urn).to end_with(":f:0.combsuffixspaced-true")
      expect(Pubid.parse_urn(urn).to_hash).to eq(id.to_hash)
    end

    it "refuses a facet value that is not a boolean" do
      bad = urn.sub("combsuffixspaced-true", "combsuffixspaced-yes")
      expect { Pubid.parse_urn(bad) }
        .to raise_error(Pubid::Errors::UrnParseError, /not a boolean/)
    end
  end
end
