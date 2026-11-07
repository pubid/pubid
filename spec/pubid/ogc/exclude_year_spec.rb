# frozen_string_literal: true

require "spec_helper"

# The "<yy>" token is OGC's core identity — the grammar's printed form is
# `<yy>-<nnn>` and its parse demands the year run — so excluding it cannot
# leave a valid identifier: the exclusion nilled the year and the renderer
# printed the dangling separator ("-000", "-002r1"), the relaton corpus
# gate's ogc-fuzz failures (run 42204581379, 114 NEW). An exclusion that
# would leave the identifier unprintable is not a mutation, so :year is a
# no-op; every other key behaves as the base #exclude does.
RSpec.describe "Pubid::Ogc exclude(:year) is a no-op" do
  let(:id) do
    Pubid::Ogc::Identifier.from_hash(
      { "_type" => "pubid:ogc:document", "year" => "20",
        "number" => "000", "revision" => "r1" },
    )
  end

  it "renders the core with the year" do
    expect(id.to_s).to eq("20-000r1")
  end

  it "exclude(:year) answers the same identifier" do
    excluded = id.exclude(:year)
    expect(excluded.to_s).to eq("20-000r1")
    expect(excluded).to eq(id)
  end

  it "exclude(:revision) still strips the revision" do
    expect(id.exclude(:revision).to_s).to eq("20-000")
  end

  it "exclude(:number) still strips the number but keeps the year face rule" do
    excluded = id.exclude(:number)
    expect(excluded.number).to be_nil
  end

  it "matches? with ignore: [:year] stays a year-wildcard query that holds" do
    other = Pubid::Ogc::Identifier.from_hash(
      { "_type" => "pubid:ogc:document", "year" => "12",
        "number" => "000", "revision" => "r1" },
    )
    # A different year is still a different document: the exclusion is a
    # no-op, so the comparison is the strict one.
    expect(id.exclude(:year) == other.exclude(:year)).to be false
  end
end
