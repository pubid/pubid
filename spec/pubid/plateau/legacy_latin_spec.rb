require "spec_helper"

# Legacy Latin PLATEAU references (as they appear in relaton-data-plateau's
# index-v1) must parse to the *canonical* identifier, so a Latin query resolves
# the same record as the canonical one. Latin is an accepted input alias only;
# to_s/to_hash output stays canonical.
RSpec.describe "Pubid::Plateau legacy Latin references" do
  # legacy Latin input  =>  canonical identifier it must equal
  {
    # Handbook: Latin edition X.Y  ->  第X.Y版
    "PLATEAU Handbook #00 1.0" => "PLATEAU Handbook #00 第1.0版",
    "PLATEAU Handbook #01 5.1" => "PLATEAU Handbook #01 第5.1版",
    "PLATEAU Handbook #00 6.0" => "PLATEAU Handbook #00 第6.0版",
    # Handbook with dash annex + Latin edition
    "PLATEAU Handbook #03-1 3.0" => "PLATEAU Handbook #03-1 第3.0版",
    # Technical Report: Latin edition dropped
    "PLATEAU Technical Report #00 1.0" => "PLATEAU Technical Report #00",
    "PLATEAU Technical Report #101 1.0" => "PLATEAU Technical Report #101",
    # Technical Report: underscore sub-number -> dash, edition dropped
    "PLATEAU Technical Report #46_1 1.0" => "PLATEAU Technical Report #46-1",
    "PLATEAU Technical Report #46_2 1.0" => "PLATEAU Technical Report #46-2",
    # Technical Report: underscore sub-number, no edition
    "PLATEAU Technical Report #46_1" => "PLATEAU Technical Report #46-1",
  }.each do |latin, canonical|
    context latin.inspect do
      it "parses to the same identifier as #{canonical.inspect}" do
        from_latin     = Pubid::Plateau.parse(latin)
        from_canonical = Pubid::Plateau.parse(canonical)

        expect(from_latin.to_s).to eq(canonical)
        expect(from_latin.to_s).to eq(from_canonical.to_s)
        expect(from_latin.to_hash).to eq(from_canonical.to_hash)

        # Canonical no-defaults hash round-trips idempotently (relaton-index
        # relies on this equality — see CLAUDE.md).
        expect(from_latin.class.from_hash(from_latin.to_hash).to_hash)
          .to eq(from_latin.to_hash)
      end
    end
  end

  # A Latin edition / underscore annex combined with an "Annex X" supplement
  # normalizes through the wrapper too. (Only to_s is asserted: the annex
  # SupplementIdentifier's to_hash is independently unsupported today — it
  # raises for the canonical form as well — so serialization equality is out of
  # scope for this Latin-input change.)
  {
    "PLATEAU Handbook #00 1.0 Annex A" =>
      "PLATEAU Handbook #00 第1.0版 Annex A",
    "PLATEAU Technical Report #46_1 Annex A" =>
      "PLATEAU Technical Report #46-1 Annex A",
  }.each do |latin, canonical|
    it "normalizes annex-supplement #{latin.inspect} to #{canonical.inspect}" do
      expect(Pubid::Plateau.parse(latin).to_s).to eq(canonical)
      expect(Pubid::Plateau.parse(latin).to_s)
        .to eq(Pubid::Plateau.parse(canonical).to_s)
    end
  end

  it "does not regress the canonical forms" do
    expect(Pubid::Plateau.parse("PLATEAU Handbook #00 第1.0版").to_s)
      .to eq("PLATEAU Handbook #00 第1.0版")
    expect(Pubid::Plateau.parse("PLATEAU Technical Report #46-1").to_s)
      .to eq("PLATEAU Technical Report #46-1")
    expect(Pubid::Plateau.parse("PLATEAU Technical Report #01").to_s)
      .to eq("PLATEAU Technical Report #01")
  end
end
