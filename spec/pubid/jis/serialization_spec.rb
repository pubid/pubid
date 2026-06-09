# frozen_string_literal: true

require "spec_helper"

# Round-trip invariant for index serialization: a parsed JIS identifier must
# survive `to_hash` → `from_hash` unchanged. This is the contract the Relaton
# index relies on (store `id.to_hash`, rebuild via `from_hash`). Drives the
# lutaml-model serialization work and stays red until JIS identifiers are
# lutaml-native.
RSpec.describe "Pubid::Jis identifier hash round-trip" do
  refs = [
    "JIS A 0001:1999",                          # plain standard
    "JIS B 0205-1:2001",                        # with part
    "JIS C 61000-3-2:2019",                     # multi-level parts
    "JIS Z 8301:2019(E)",                       # language
    "JIS C 0617（規格群）",                      # all-parts notation
    "JIS C 9901:2019R",                         # reaffirmation
    "JIS TR A 0001:1996",                       # technical report
    "JIS TS Z 0030-1:2017",                     # technical specification
    "JIS Z 8210:2017 SYMBOL 61700",             # symbol sub-reference
    "JIS Z 8211-1:2025 SYMBOL",                 # bare symbol keyword
    "JIS A 0001:1999/AMD 1:2000",               # amendment
    "JIS B 3700-11:1996/CORRIGENDUM 1:2002",    # corrigendum
    "JIS K 2249-4:2011/EXPL 4",                 # explanation
    "JIS Z 8210:2017/AMD 1:2019 SYMBOL 51590",  # supplement + symbol
  ]

  refs.each do |ref|
    describe ref do
      let(:identifier) { Pubid::Jis::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash" do
        expect(hash).not_to be_empty
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::Jis::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end
    end
  end
end
