# frozen_string_literal: true

require "spec_helper"

# AMCA `to_s` and `to_urn` for every identifier type.
#
# The renderer put a space before the year ("AMCA Publication 211 -22"),
# dropped "Interp" and printed "(R2010)" as "(2010)". The URN generator
# interpolated the `type` metadata Hash into every AMCA URN
# ("copub.amca:{key: :publication, ...}").
RSpec.describe "Pubid::Amca rendering" do
  describe "#to_s" do
    [
      "AMCA Publication 211-22 (Rev. 01-23)",
      "AMCA Publication 311-16",
      "AMCA Publication 1011-03 (R2010)",
      "AMCA 99 JW Interp",
      "AMCA 511 Interp",
      "ANSI/AMCA 204 Interp",
      "AMCA Standard 803-02 (R2008)",
      "ANSI/AMCA Standard 220-21",
    ].each do |ref|
      it "renders #{ref} as it was written" do
        expect(Pubid::Amca.parse(ref).to_s).to eq(ref)
      end
    end
  end

  describe "#to_urn" do
    {
      "AMCA 99 JW Interp" => "urn:amca:99:interp.jw:copub.amca:interpretation",
      "AMCA Publication 211-22 (Rev. 01-23)" =>
        "urn:amca:211:22:rev.01-23:copub.amca:publication",
      "ANSI/AMCA Standard 220-21" => "urn:amca:220:21:copub.ansi/amca:standard",
    }.each do |ref, urn|
      it "names the type of #{ref} by its key" do
        expect(Pubid::Amca.parse(ref).to_urn).to eq(urn)
      end
    end

    it "gives distinct interpretations distinct URNs" do
      urns = ["AMCA 99 JW Interp", "AMCA 99 KB Interp"]
        .map { |ref| Pubid::Amca.parse(ref).to_urn }
      expect(urns.uniq.size).to eq(2)
    end

    it "never leaks a Ruby Hash" do
      Dir.glob(File.join(__dir__, "../../fixtures/amca/identifiers/full/*.txt"))
        .flat_map { |f| File.readlines(f, chomp: true) }
        .reject { |l| l.strip.empty? || l.start_with?("#") }
        .each do |line|
          urn = begin
            Pubid::Amca.parse(line).to_urn
          rescue Parslet::ParseFailed
            next
          end
          expect(urn).not_to include("{"), line
        end
    end
  end
end
