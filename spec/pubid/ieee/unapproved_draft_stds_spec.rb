# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEEE unapproved drafts must not render 'Std' — issue #209" do
  # IEEE staff guidance: an "unapproved draft" is not yet a standard, so the
  # "Std" token must not appear in the rendered identifier. The whole type
  # word goes, not just "Std": the status word already says it is a draft,
  # and the literal "Draft" is a bare parse marker that cannot survive a
  # re-parse — rendering it made to_s need three rounds to converge while
  # losing the type (issue #318). The corpus canonicals agree
  # ("IEEE Unapproved 802.1ah/D4.2", "IEEE Unapproved P1137/D2"). The D1-D6
  # registry stages carry the project P, so a fabricated /D1 renders with it.
  {
    "IEEE Unapproved Draft Std 802.3" => "IEEE Unapproved P802.3/D1",
    "IEEE Unapproved Std 802.3" => "IEEE Unapproved 802.3",
    "IEEE Unapproved Draft Std P802.3" => "IEEE Unapproved P802.3/D1",
  }.each do |input, expected|
    it "renders #{input.inspect} as #{expected.inspect}" do
      parsed = Pubid::Ieee.parse(input)
      expect(parsed.to_s).to eq(expected)
      expect(parsed.to_s).not_to match(/\bStd\b/)
    end
  end

  it "drops 'Std' but keeps the year for dated unapproved drafts" do
    parsed = Pubid::Ieee.parse("IEEE Unapproved Draft Std 802.3-2018")
    expect(parsed.to_s).to include("2018")
    expect(parsed.to_s).not_to match(/\bStd\b/)
  end

  it "still renders 'Std' for approved standards" do
    parsed = Pubid::Ieee.parse("IEEE Std 802.3-2018")
    expect(parsed.to_s).to eq("IEEE Std 802.3-2018")
  end

  it "still renders 'Draft Std' for dotted-version drafts" do
    parsed = Pubid::Ieee.parse("IEEE Draft Std P802.3/D2.0/Cor. 1")
    expect(parsed.to_s).to eq("IEEE Draft Std P802.3/D2.0/Cor. 1")
  end
end
