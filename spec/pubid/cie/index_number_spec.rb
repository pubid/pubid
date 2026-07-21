# frozen_string_literal: true

require "spec_helper"

# relaton-index narrows candidate matches with a binary search keyed on a
# document's number. After the base_identifier -> base / #root refactor (#139)
# the uniform, depth-independent key is `id.root.number`: #root walks `base` to
# the origin document (a supplement/corrigendum keys under its root standard),
# and a leaf document is its own root. If that key is the empty string the row
# clusters at the front of the sorted index and defeats the binary search.
#
# Every CIE identifier must therefore expose a non-empty `root.number`. Wrappers
# get this for free from #139 (root -> leaf standard). This spec locks the
# invariant for the whole flavor, in particular the leaf forms that previously
# had no number at all: standalone proceedings, bundle, tutorial bundle.
RSpec.describe "Pubid::Cie relaton-index number coverage" do
  # A comma-separated bundle (its own number comes from the first item).
  bundle = "CIE 198-SP1.1:2011,198-SP1.2:2011," \
           "198-SP1.3:2011,198-SP1.4:2011"

  # The relaton-index narrowing key.
  def index_key(id)
    id.root.number.to_s
  end

  # One representative per CIE identifier family, including the forms that
  # previously collapsed to "".
  cases = {
    "standard" => "CIE 015:2018",
    "conference" => "CIE x005-1992",
    "dual_published" => "CIE S 009:2002/IEC 62471:2006",
    "joint_published" => "CIE ISO 10916:2024",
    "identical" => "CIE S 006.1/1998 (ISO 16508:1999)",
    "proceedings x-form" => "CIE x043-OP01",
    "proceedings standalone" => "CIE OP02 1-5",
    "supplement" => "CIE 121-SP1:2009",
    "corrigendum (1-level)" => "CIE 232:2019/Cor1:2020",
    "corrigendum (2-level)" => "CIE 198-SP1.4:2011/Cor1:2013",
    "bundle" => bundle,
    "tutorial_bundle" => "CIE Tutorials Bundle 1",
  }

  cases.each do |family, ref|
    it "yields a non-empty root.number for #{family} (#{ref})" do
      expect(index_key(Pubid::Cie.parse(ref))).not_to be_empty
    end
  end

  # Spot-check the specific keys so a future refactor can't silently change the
  # grouping. Wrappers group under their root standard's number (at any depth);
  # leaves under their own number.
  {
    "CIE 121-SP1:2009" => "121",             # supplement -> root standard
    "CIE 232:2019/Cor1:2020" => "232",       # corrigendum -> root standard
    "CIE 198-SP1.4:2011/Cor1:2013" => "198", # corrig-of-supp -> root standard
    "CIE OP02 1-5" => "OP02",                # standalone paper -> paper string
    "CIE x043-OP01" => "OP01",               # x-form paper -> paper string
    "CIE Tutorials Bundle 1" => "1",         # tutorial bundle -> ordinal
    bundle => "198",                         # bundle -> first item's number
  }.each do |ref, expected|
    it "keys #{ref} as #{expected.inspect}" do
      expect(index_key(Pubid::Cie.parse(ref))).to eq(expected)
    end
  end
end
