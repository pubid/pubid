# frozen_string_literal: true

# The per-flavor `Identifier` *module* facades (NIST, IHO, BSI, CEN/CENELEC,
# ASHRAE) are handed to consumers such as relaton-index as a `pubid_class`.
# Unlike the class-based flavors (ISO, IEC, …) the module is not in the
# identifier's ancestry and has no `from_hash`, so a consumer cannot deserialize
# or identity-check through it. `Pubid::IdentifierFacade` closes that gap; these
# specs lock in the contract.
#
# Facade opt-in is gated to flavors whose to_hash/from_hash round-trips cleanly,
# so the identity check and the from_hash round-trip cover the same set. The
# excluded module flavors (AMCA, ITU, PLATEAU, IEEE) deliberately do NOT opt in
# (broken/lossy serialization); the "gated flavors" group below pins that.
#
# These are file-scope locals (not constants) so the example-group blocks close
# over them without leaking names into the global namespace.
facade_samples = {
  Ashrae: "ASHRAE 55-2017",
  Bsi: "BS 5839-1:2017",
  CenCenelec: "EN 50128:2011",
  Iho: "IHO S-57",
  Nist: "NIST IR 88-4008",
}.freeze

# Module-pattern flavors intentionally excluded from the facade rollout (see
# the NOTE in each flavor's identifier.rb). A sample that parses is enough.
facade_gated_flavors = {
  Amca: "AMCA 200",
  Itu: "ITU-T G.711",
  Plateau: "PLATEAU Handbook #00",
  Ieee: "IEEE 802.3-2018",
}.freeze

RSpec.describe Pubid::IdentifierFacade do
  describe "identity check (is_a? / ===)" do
    facade_samples.each do |flavor, ref|
      context "#{flavor} (#{ref})" do
        let(:mod) { Pubid.const_get(flavor)::Identifier }
        let(:id)  { mod.parse(ref) }

        it "the parsed identifier is_a? the facade module" do
          expect(id).to be_a(mod)
        end

        it "the facade module === the parsed identifier" do
          expect(mod === id).to be true
        end

        it "the facade module exposes from_hash" do
          expect(mod).to respond_to(:from_hash)
        end
      end
    end
  end

  describe "polymorphic from_hash round-trip" do
    facade_samples.each do |flavor, ref|
      context "#{flavor} (#{ref})" do
        let(:mod) { Pubid.const_get(flavor)::Identifier }
        let(:id)  { mod.parse(ref) }

        it "from_hash returns the same concrete class parse produced" do
          restored = mod.from_hash(id.to_hash)
          expect(restored.class).to eq(id.class)
        end

        it "from_hash round-trips to_s" do
          restored = mod.from_hash(id.to_hash)
          expect(restored.to_s).to eq(id.to_s)
        end
      end
    end
  end

  # The concrete scenario from the relaton-index contract: a NIST id stored in
  # an index row and re-read. relaton-nist passes Pubid::Nist::Identifier as the
  # pubid_class, then calls `value.is_a?(pubid_class)` on save and
  # `pubid_class.from_hash(raw)` on load.
  describe "Pubid::Nist::Identifier (relaton-index contract)" do
    let(:mod) { Pubid::Nist::Identifier }
    let(:id)  { mod.parse("NIST IR 88-4008") }

    it "dispatches from_hash to the concrete subclass via _type" do
      restored = mod.from_hash(id.to_hash)
      expect(restored).to be_a(Pubid::Nist::Identifiers::InteragencyReport)
    end

    it "round-trips to_s through to_hash/from_hash" do
      expect(mod.from_hash(id.to_hash).to_s).to eq(id.to_s)
    end

    it "satisfies is_a? (save path: value.is_a?(pubid_class))" do
      expect(id).to be_a(mod)
    end

    it "every NIST identifier type is_a? the facade module" do
      Pubid::Nist.identifier_types.each do |klass|
        expect(klass.ancestors).to include(mod)
      end
    end

    it "from_hash falls back to Base for an unknown _type" do
      restored = mod.from_hash("_type" => "pubid:nist:does-not-exist",
                               "series" => { "value" => "XYZ" })
      expect(restored).to be_a(Pubid::Nist::Identifiers::Base)
    end
  end

  # Gate guard: these flavors have broken/lossy serialization, so enabling the
  # facade would route their ids through a consumer's `to_hash` (relaton-index
  # #save) and crash, or load them silently lossy. Pin that they stay opted out
  # until their serialization is fixed — re-enabling without a fix should fail
  # here, not in a downstream relaton gem.
  describe "gated flavors stay opted out of the facade" do
    facade_gated_flavors.each do |flavor, ref|
      context "#{flavor} (#{ref})" do
        let(:mod) { Pubid.const_get(flavor)::Identifier }
        let(:id)  { mod.parse(ref) }

        it "does not extend the facade" do
          expect(mod).not_to be_a(Pubid::IdentifierFacade)
        end

        it "parsed identifier is not is_a? the module" do
          expect(id).not_to be_a(mod)
        end
      end
    end
  end
end
