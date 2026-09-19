# frozen_string_literal: true

require "spec_helper"

# A supplement URN is the URN of its base, plus one segment that names the
# supplement. The segment is the same marker the MR slug uses
# (`mr_supplement_suffix`), so the two surfaces cannot drift apart.
# (hand-off: ashrae-supplement-urn-collapse)
RSpec.describe "ASHRAE supplement URN" do
  def urn(ref)
    Pubid::Ashrae.parse(ref).to_urn.to_s
  end

  {
    "ASHRAE Addendum e to Guideline 28-2016" =>
      "urn:ashrae:28:2016:guideline:add.e",
    "ASHRAE Guideline 0: Addenda a, b, c, d" =>
      "urn:ashrae:0:guideline:adds.a-b-c-d",
    "ASHRAE Guideline 14-2002 Errata (October 10, 2008)" =>
      "urn:ashrae:14:2002:guideline:errata.2008-10-10",
    "Interpretations for Standard 15.2-2022" =>
      "urn:ashrae:15.2:2022:standard:interp",
    "ASHRAE Standard 15-2007 Addenda Supplement Package" =>
      "urn:ashrae:15:2007:standard:pkg.supplement-package",
  }.each do |ref, expected|
    it "gives #{ref.inspect} the URN #{expected}" do
      expect(urn(ref)).to eq(expected)
    end
  end

  it "keeps the URN of a plain standard as it was" do
    expect(urn("ASHRAE Guideline 28-2016"))
      .to eq("urn:ashrae:28:2016:guideline")
    expect(urn("ASHRAE Standard 90.1-2019"))
      .to eq("urn:ashrae:90.1:2019:standard")
  end

  it "gives two addenda of one base two URNs" do
    expect(urn("ASHRAE Addendum d to Guideline 28-2016"))
      .not_to eq(urn("ASHRAE Addendum e to Guideline 28-2016"))
  end

  it "gives two errata of one base two URNs" do
    expect(urn("ASHRAE Guideline 14-2002 Errata (October 10, 2008)"))
      .not_to eq(urn("ASHRAE Guideline 14-2002 Errata (October 20, 2008)"))
  end

  # The builder always sets `base`. A hand-built supplement can omit it, and
  # then takes the plain-document path instead of raising.
  it "gives a supplement with no base the plain-document URN" do
    erratum = Pubid::Ashrae::Identifiers::Errata.new
    expect(erratum.to_urn.to_s).to eq("urn:ashrae")
  end

  it "starts a supplement URN with the URN of its base, and adds to it" do
    base = urn("ASHRAE Guideline 28-2016")
    supplement = urn("ASHRAE Guideline 28-2016 Errata (June 2021)")

    expect(supplement).to start_with("#{base}:")
    expect(supplement).not_to eq(base)
  end
end
