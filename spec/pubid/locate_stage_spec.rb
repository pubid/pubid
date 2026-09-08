# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# Cross-flavor typed-stage lookup (pubid#360 item 5).
#
# Each of the 44 flavor modules memoises `all_typed_stages` over its own
# Identifiers namespace, and nothing spans them: `Pubid::Iso.locate_stage("ADTS")`
# is nil while `Pubid::Iec.locate_stage("ADTS")` finds it. A consumer holding a
# stage abbreviation but not the owning flavor had nowhere to ask.
RSpec.describe "Pubid.locate_stage" do
  describe "with an explicit flavor" do
    it "finds an IEC-only abbreviation in IEC" do
      expect(Pubid.locate_stage("ADTS", flavor: :iec)).not_to be_nil
    end

    it "does not find an IEC-only abbreviation in ISO" do
      expect(Pubid.locate_stage("ADTS", flavor: :iso)).to be_nil
    end

    it "finds a shared abbreviation in ISO" do
      stage = Pubid.locate_stage("DIS", flavor: :iso)

      expect(stage).not_to be_nil
      expect(stage.abbr).to include("DIS")
    end

    it "is case-insensitive, like the flavor methods" do
      expect(Pubid.locate_stage("adts", flavor: :iec)).not_to be_nil
    end

    it "returns the same object as the flavor module" do
      expect(Pubid.locate_stage("ADTS", flavor: :iec))
        .to eq(Pubid::Iec.locate_stage("ADTS"))
    end

    it "raises for an unregistered flavor" do
      expect { Pubid.locate_stage("DIS", flavor: :nope) }
        .to raise_error(ArgumentError, /unknown flavor/)
    end

    it "returns nil for an abbreviation no flavor uses" do
      expect(Pubid.locate_stage("ZZZZ", flavor: :iso)).to be_nil
    end
  end

  describe "without a flavor" do
    # The issue's cases: metanorma-iso looked these up through the ISO table
    # and got nothing.
    %w[ADTS PNW A2CD ACDV].each do |abbr|
      it "finds #{abbr} across flavors" do
        expect(Pubid.locate_stage(abbr)).not_to be_nil
      end
    end

    it "returns nil for an abbreviation no flavor uses" do
      expect(Pubid.locate_stage("ZZZZ")).to be_nil
    end

    it "handles nil and empty input without raising" do
      expect { Pubid.locate_stage(nil) }.not_to raise_error
      expect { Pubid.locate_stage("") }.not_to raise_error
    end

    # adobe, easc and gost define no locate_stage at all; a cross-flavor sweep
    # must skip them rather than blow up on the first one it reaches.
    it "skips flavors that do not implement locate_stage" do
      expect { Pubid.locate_stage("DIS") }.not_to raise_error
    end
  end

  describe "flavors_for" do
    it "names every flavor that knows an abbreviation" do
      expect(Pubid.locate_stage_flavors("ADTS")).to include(:iec)
    end

    it "is empty for an unknown abbreviation" do
      expect(Pubid.locate_stage_flavors("ZZZZ")).to be_empty
    end
  end
end

# The ISO half of the same area: a dangling reference to the class removed in
# e3c19ea1 ("Remove Scheme from ISO and IEC flavors"). The IEC twin was
# migrated; ISO was missed, so any from_hash whose stage code is absent from
# the class's own TYPED_STAGES raised NameError instead of falling back.
RSpec.describe "Pubid::Iso stage_from_kv fallback" do
  it "no longer calls the removed Scheme class" do
    expect(defined?(Pubid::Iso::Scheme)).to be_nil

    # Strip comments first: the fix carries a comment naming the class it
    # replaced, and a bare text search would match that instead of a call.
    code = File.read("lib/pubid/iso/identifier.rb")
               .lines.reject { |l| l.strip.start_with?("#") }.join

    expect(code).not_to include("Iso::Scheme")
  end

  it "falls back to the flavor-wide table for a code the class does not list" do
    hash = Pubid::Iso.parse("ISO/DIS 10303-62").to_hash

    expect { Pubid::Iso::Identifier.from_hash(hash) }.not_to raise_error
  end

  it "resolves a stage code through the flavor table" do
    expect(Pubid::Iso.locate_stage_by_code("pubcor")).not_to be_nil
  end

  # The branch that used to raise: a code that no single identifier class lists
  # but the flavor-wide table does. Reached through the shared handle, which is
  # what a relaton index row deserializes through.
  it "resolves a corrigendum stage code that a bare class lookup would miss" do
    stage = Pubid::Iso.locate_stage_by_code("dcor")

    expect(stage).not_to be_nil
    expect(stage.abbr).to include("DCor")
  end
end
