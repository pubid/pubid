# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEC stage codes — issue #237" do
  let(:all_stages) { Pubid::Iec.all_typed_stages }
  let(:all_abbrs) { all_stages.map(&:abbr).flatten.map(&:to_s).sort.uniq }

  ISSUE_ABBRS = %w[
    ACD ACDV ADTR ADTS A2CD 2CD 3CD 4CD 5CD 6CD 7CD 8CD 9CD
    A3CD A4CD A5CD A6CD A7CD A8CD A9CD
    BPUB PPUB APUB WPUB DELPUB AMW RR
    NFDIS NDTR NDTS DTSM DTRM CDM CDVM CCDV NCDV CAN
    NADIS RDISH RFDIS CDTR CDTS CFDIS
    PNW NWIP BWG AWIN
  ].freeze

  it "covers every abbreviation from the issue body" do
    missing = ISSUE_ABBRS - all_abbrs
    expect(missing).to be_empty,
                           "these abbrs are not in any typed stage: #{missing.inspect}"
  end

  it "CD stage accepts iteration suffixes (2CD..9CD, ACD, A2CD..A9CD)" do
    cd = all_stages.find { |s| s.code.to_s == "cd" }
    expect(cd.abbr.map(&:to_s)).to include("2CD", "ACD", "A9CD")
  end

  # PNW used to be listed here as a PWI variant. It is a stage of its own at
  # harmonized code 10.20 — see spec/pubid/iec/pnw_stage_spec.rb and issue
  # #360. The ISSUE_ABBRS example above still covers PNW, because that example
  # only asserts the abbreviation is registered somewhere.
  it "PWI stage accepts work-item variants (NWIP, BWG, AWIN, AMW)" do
    pwi = all_stages.find { |s| s.code.to_s == "pwi" }
    expect(pwi.abbr.map(&:to_s)).to include("NWIP", "BWG", "AWIN", "AMW")
    expect(pwi.abbr.map(&:to_s)).not_to include("PNW")
  end

  it "published stage accepts publication variants (BPUB, PPUB, APUB, WPUB, DELPUB)" do
    pub = all_stages.find { |s| s.stage_code.to_s == "published" && s.code.to_s == "is" }
    expect(pub.abbr.map(&:to_s)).to include("BPUB", "PPUB", "APUB", "WPUB", "DELPUB")
  end
end
