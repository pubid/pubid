# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# Cross-flavor contract for the uniform `.prefixes` API used by relaton's
# global prefix register (routes a reference string to the owning flavor).
RSpec.describe "Flavor prefixes API" do
  describe "uniform contract across every registered flavor" do
    Pubid::Registry.flavor_names.each do |flavor_name|
      context flavor_name do
        let(:mod) { Pubid::Registry.get(flavor_name) }

        it "responds to .prefixes" do
          expect(mod).to respond_to(:prefixes)
        end

        it "returns a non-empty frozen Array of non-blank, unique Strings" do
          prefixes = mod.prefixes
          expect(prefixes).to be_an(Array)
          expect(prefixes).to be_frozen
          expect(prefixes).not_to be_empty
          expect(prefixes).to all(be_a(String))
          expect(prefixes).to all(satisfy { |s| !s.strip.empty? })
          expect(prefixes.uniq).to eq(prefixes)
        end
      end
    end
  end

  describe "static call path (no parsing)" do
    it "does not parse when enumerating prefixes" do
      allow(Pubid::Iso).to receive(:parse)
      allow(Pubid::Bsi).to receive(:parse)
      Pubid::Iso.prefixes
      Pubid::Bsi.prefixes
      expect(Pubid::Iso).not_to have_received(:parse)
      expect(Pubid::Bsi).not_to have_received(:parse)
    end
  end

  describe "acceptance minimums" do
    it "ISO owns ISO, ISO/IEC and ISO/IEC/IEEE" do
      expect(Pubid::Iso.prefixes).to include("ISO", "ISO/IEC", "ISO/IEC/IEEE")
    end

    it "IEC owns IEC and ISO/IEC" do
      expect(Pubid::Iec.prefixes).to include("IEC", "ISO/IEC")
    end

    it "IEEE owns IEEE and ISO/IEC/IEEE" do
      expect(Pubid::Ieee.prefixes).to include("IEEE", "ISO/IEC/IEEE")
    end

    it "BSI owns DD and PD (the non-obvious BSI prefixes)" do
      expect(Pubid::Bsi.prefixes).to include("BS", "BSI", "DD", "PD")
    end

    it "NIST owns NIST, NBS and reference-leading series" do
      expect(Pubid::Nist.prefixes).to include("NIST", "NBS", "FIPS", "SP")
    end
  end

  describe "joint-publication symmetry" do
    it "lists ISO/IEC under every co-publisher" do
      expect(Pubid::Iso.prefixes).to include("ISO/IEC")
      expect(Pubid::Iec.prefixes).to include("ISO/IEC")
    end

    it "lists ISO/IEC/IEEE under all three co-publishers" do
      expect(Pubid::Iso.prefixes).to include("ISO/IEC/IEEE")
      expect(Pubid::Iec.prefixes).to include("ISO/IEC/IEEE")
      expect(Pubid::Ieee.prefixes).to include("ISO/IEC/IEEE")
    end

    it "lists ANSI/ASHRAE under both ANSI and ASHRAE" do
      expect(Pubid::Ansi.prefixes).to include("ANSI/ASHRAE")
      expect(Pubid::Ashrae.prefixes).to include("ANSI/ASHRAE")
    end

    it "lists ANSI/AMCA under both ANSI and AMCA" do
      expect(Pubid::Ansi.prefixes).to include("ANSI/AMCA")
      expect(Pubid::Amca.prefixes).to include("ANSI/AMCA")
    end
  end

  describe "exclusion policy" do
    it "excludes BSI's dangerously-ambiguous aerospace single letters" do
      expect(Pubid::Bsi.prefixes).not_to include("A", "B", "C", "S", "X")
    end
  end

  describe "Pubid.prefixes(flavor)" do
    it "delegates to the flavor module" do
      expect(Pubid.prefixes(:iso)).to eq(Pubid::Iso.prefixes)
      expect(Pubid.prefixes("bsi")).to eq(Pubid::Bsi.prefixes)
    end

    it "raises ArgumentError for an unknown flavor" do
      expect { Pubid.prefixes(:nope) }
        .to raise_error(ArgumentError, /unknown flavor/)
    end
  end

  describe "Pubid.prefix_flavors" do
    subject(:index) { Pubid.prefix_flavors }

    it "returns a Hash of prefix => sorted flavor symbols" do
      expect(index).to be_a(Hash)
      expect(index["ISO"]).to eq([:iso])
      expect(index["ISO/IEC"]).to eq(%i[iec iso])
      expect(index["ISO/IEC/IEEE"]).to eq(%i[iec ieee iso])
    end

    it "attributes CEN/CENELEC prefixes to :cen_cenelec, not the :cen alias" do
      expect(index["EN"]).to include(:cen_cenelec)
      index.each_value do |flavors|
        expect(flavors).not_to include(:cen)
        # the alias must never double-count a module
        expect(flavors.count(:cen_cenelec)).to be <= 1
      end
    end

    it "routes the non-obvious BSI prefix DD to :bsi" do
      expect(index["DD"]).to include(:bsi)
    end
  end
end
