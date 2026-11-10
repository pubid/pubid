# frozen_string_literal: true

require "spec_helper"

# Facets are spelling only (issue #656): two spellings of one document are
# ==, share a hash and match with === in both directions, while a value
# that names another document stays identity. The corpus-wide guard is the
# facet-cut example in spec/pubid/pubid_urn_contract_spec.rb; these pairs
# show the rule on real inputs.
RSpec.describe "facets and identity" do
  def parse(flavor, input)
    Pubid::Registry.get(flavor).parse(input)
  end

  before { Pubid.eager_load_flavors! }

  {
    "NIST revision prefix" => ["nist", "NIST SP 800-53 Rev. 5", 
                               "NIST SP 800-53r5"],
    "ISO language spelling" => ["iso", "ISO 9001:2015(E)", "ISO 9001:2015(en)"],
  }.each do |name, (flavor, first, second)|
    describe name do
      let(:a) { parse(flavor, first) }
      let(:b) { parse(flavor, second) }

      it "keeps both spellings" do
        expect(a.to_s).not_to eq(b.to_s)
      end

      it "is == and eql? with one hash" do
        expect(a).to eq(b)
        expect(a).to eql(b)
        expect(a.hash).to eq(b.hash)
      end

      it "matches with === in both directions" do
        expect(a === b).to be(true)
        expect(b === a).to be(true)
      end
    end
  end

  {
    "EVS draft" => ["evs", "prEVS-EN 100:2026", "EVS-EN 100:2026"],
    "CSA French edition" => ["csa", "CSA B149.1:F20", "CSA B149.1:20"],
  }.each do |name, (flavor, first, second)|
    describe name do
      let(:a) { parse(flavor, first) }
      let(:b) { parse(flavor, second) }

      # The reverse direction is not asserted: a nil value is a wildcard of
      # the subset match, so "CSA B149.1:20" (no French marker) as a
      # reference matches the French edition, as a language-less ISO
      # reference matches every language.
      it "is another document under == and ===" do
        expect(a).not_to eq(b)
        expect(a === b).to be(false)
      end

      it "has another pubid-scheme URN with the facets cut" do
        cut = ->(urn) { urn.split(":f:").first }
        expect(cut.call(a.to_pubid_urn)).not_to eq(cut.call(b.to_pubid_urn))
      end
    end
  end

  # The builder maps only R, F, E, A, S and D to a code; another letter
  # leaves the code nil, and its spelling is then the language itself.
  describe "an unmapped one-letter language" do
    let(:x) { parse("iso", "ISO 1234(X)") }
    let(:q) { parse("iso", "ISO 1234(Q)") }

    it "keeps two such languages apart under == and ===" do
      expect(x).not_to eq(q)
      expect(x === q).to be(false)
      expect(q === x).to be(false)
    end

    it "does not match a mapped language under ===" do
      expect(x === parse("iso", "ISO 1234(R)")).to be(false)
    end
  end
end
