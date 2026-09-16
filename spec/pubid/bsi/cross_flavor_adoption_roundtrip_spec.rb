# frozen_string: true

require "spec_helper"

# pubid#379: Pubid.from_hash could not rehydrate an identifier whose
# `adopted` is a nested CROSS-FLAVOR identifier. The BSI adoption wrappers
# delegate `date` (and `type`) to the foreign object they wrap, but the
# outer attribute table demanded the empty BSI subclasses
# (Bsi::Components::Date < Pubid::Components::Date adds nothing), so
# serialization rejected the shared component the inner flavor carries —
# "BS EN …"/"BS ISO …" raised IncorrectModelError on to_hash, and the
# round-trip was impossible. The same empty-subclass mismatch on `type`
# broke the BIP/PP/HB leaves. Retyping both attributes to the shared
# components (the bsi-set-cross-flavor-type precedent) fixes the whole
# family, EVS national adoptions included.
RSpec.describe "BSI cross-flavor adoption round-trip — issue #379" do
  [
    "BS EN 10077-1:2006",
    "BS EN ISO 8601:2019",
    "BS ISO 8601:2019",
    "BS IEC 62600:2020",
    "PD ISO/TS 12180-1:2007",
    "NA+A1:2012 to BS EN 1090-2:2018",
    "BIP 2225:2022",
    "PP 888:1982",
    "HB 10146:1998",
  ].each do |input|
    context input.inspect do
      it "round-trips through Pubid.from_hash with an identical hash" do
        hash = Pubid.parse(input).to_hash
        expect(Pubid.from_hash(hash).to_hash).to eq(hash)
      end

      it "re-renders the same string" do
        expect(Pubid.from_hash(Pubid.parse(input).to_hash).to_s)
          .to eq(Pubid.parse(input).to_s)
      end
    end
  end

  it "round-trips an EVS national adoption of a CEN norm" do
    hash = Pubid.parse("EVS-EN 18216:2026").to_hash
    expect(Pubid.from_hash(hash).to_hash).to eq(hash)
  end
end
