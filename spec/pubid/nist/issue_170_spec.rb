# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid"

# Dotted edition minors (pubid#170): "NIST SP 800-53r4.1" is revision 4.1.
# The edition id extends to digits[.digits] and binds atomically in every
# face, so a dotted minor never migrates between number and edition slots
# (the pre-fix corruptions rendered "NBS FIPS 100r2.5" as "100-5r2" and
# "NIST SP 260-162 2006ed.1" as "260-162e20061").
RSpec.describe "Pubid::Nist dotted edition ids (pubid#170)" do
  {
    "NIST SP 800-53r4.1" => { "type" => "r", "id" => "4.1" },
    "NIST SP 800-53e2.1" => { "type" => "e", "id" => "2.1" },
    "NBS FIPS 100r2.5" => { "type" => "r", "id" => "2.5" },
    "NIST SP 260-162e2006.1" => { "type" => "e", "id" => "2006.1" },
  }.each do |input, edition|
    it "binds #{input.inspect} atomically and renders back" do
      id = Pubid::Nist.parse(input)
      expect(id.to_s).to eq(input)
      expect(id.to_hash["edition"]).to eq(edition)
      expect(Pubid::Nist.parse(id.to_s)).to eq(id)
    end
  end

  it "keeps the minor through the edition-year shorthand" do
    id = Pubid::Nist.parse("NIST SP 260-162 2006ed.1")
    expect(id.to_s).to eq("NIST SP 260-162e2006.1")
    expect(id.to_hash["edition"]).to eq("type" => "e", "id" => "2006.1")
  end

  it "binds the minor in the MR dot-separated face" do
    id = Pubid::Nist.parse("NIST.SP.800-53r4.1")
    expect(id.to_s).to eq("NIST.SP.800-53r4.1")
    expect(id.to_hash["edition"]).to eq("type" => "r", "id" => "4.1")
  end

  it "carries the minor into the URN" do
    expect(Pubid::Nist.parse("NIST SP 800-53r4.1").to_urn)
      .to eq("urn:nist:sp:800-53.r4.1.supp")
  end

  it "leaves dot-less editions and the index suffix unchanged" do
    expect(Pubid::Nist.parse("NIST SP 800-53r4").to_s).to eq("NIST SP 800-53r4")
    expect(Pubid::Nist.parse("NIST SP 800-53e2").to_s).to eq("NIST SP 800-53e2")
    expect(Pubid::Nist.parse("NBS NSRDS 63indx").to_s).to eq("NBS NSRDS 63indx")
  end
end
