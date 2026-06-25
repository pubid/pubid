# frozen_string_literal: true

require "spec_helper"

# Guards against lossy `to_s` rendering that dropped a parsed component
# (part / volume / supplement / edition) and so collapsed distinct NIST
# documents to the same canonical id. The relaton-data-nist crawler uses
# `to_s(format: :human)` as both the index id and the output filename, so any
# such collision silently overwrites one document with another.
#
# See the prompt: pubid-lossy-render-collisions.
RSpec.describe "NIST lossy render collisions" do
  # Each group lists source docids that are DISTINCT documents and therefore
  # MUST render to pairwise-distinct ids. Under the old (buggy) renderers the
  # dropped component made several of these collapse together.
  distinct_groups = {
    "Report parts (NBS RPT 9981)" => [
      "NBS RPT 9981",
      "NBS RPT 9981p1",
      "NBS RPT 9981p2",
      "NBS RPT 9981p5",
      "NBS RPT 9981p7",
    ],
    "Report parts (NBS RPT 3996)" => [
      "NBS RPT 3996",
      "NBS RPT 3996p1",
      "NBS RPT 3996p2",
    ],
    "FIPS volumes (NIST FIPS 55)" => [
      "NIST FIPS 55",
      "NIST FIPS 55v1",
      "NIST FIPS 55v2",
      "NIST FIPS 55v3",
      "NIST FIPS 55v4",
    ],
    "FIPS supplement (NBS FIPS 63-1)" => [
      "NBS FIPS 63-1",
      "NBS FIPS 63-1sup",
    ],
    "MiscPub supplement (NBS MP 277/278)" => [
      "NBS MP 277",
      "NBS MP 277supp1",
      "NBS MP 278",
      "NBS MP 278supp1",
    ],
    "SP letter + year edition (NIST SP 800-38)" => [
      "NIST SP 800-38a",
      "NIST SP 800-38b",
      "NIST SP 800-38b-2005",
    ],
  }.freeze

  distinct_groups.each do |label, inputs|
    context label do
      it "renders pairwise-distinct ids (no collisions)" do
        ids = inputs.map { |s| Pubid::Nist.parse(s).to_s }
        duplicates = ids.group_by(&:itself).select { |_, v| v.size > 1 }.keys
        expect(duplicates).to be_empty,
                              "expected distinct ids, got collisions #{duplicates.inspect} " \
                              "from #{inputs.inspect} => #{ids.inspect}"
        expect(ids.uniq.length).to eq(ids.length)
      end
    end
  end

  # Every source docid (and the canonical forms the prompt targets) must
  # round-trip: re-parsing the rendered id reproduces the same id.
  roundtrip_cases = [
    "NBS RPT 9981p1", "NBS RPT 9981p2", "NBS RPT 9981p5", "NBS RPT 9981p7",
    "NBS RPT 9981pt7", "NBS RPT 2447p7", "NBS RPT 3996p2",
    "NIST FIPS 55v1", "NIST FIPS 55v2", "NIST FIPS 55v3", "NIST FIPS 55v4",
    "NBS FIPS 63-1sup",
    "NBS MP 277supp1", "NBS MP 278supp1", "NBS MP 277sup1",
    "NIST SP 800-38b-2005", "NIST SP 800-38Be2005"
  ].freeze

  describe "round-trips losslessly" do
    roundtrip_cases.each do |input|
      it "round-trips #{input.inspect}" do
        rendered = Pubid::Nist.parse(input).to_s
        reparsed = Pubid::Nist.parse(rendered).to_s
        expect(reparsed).to eq(rendered)
      end
    end
  end

  # The prompt's exact source-docid => canonical-id expectations.
  {
    "NBS RPT 9981p1" => "NBS RPT 9981pt1",
    "NBS RPT 9981p7" => "NBS RPT 9981pt7",
    "NBS RPT 2447p7" => "NBS RPT 2447pt7",
    "NBS RPT 3996p2" => "NBS RPT 3996pt2",
    "NIST FIPS 55v1" => "NIST FIPS 55v1",
    "NIST FIPS 55v4" => "NIST FIPS 55v4",
    "NBS FIPS 63-1sup" => "NBS FIPS 63-1sup",
    "NBS MP 277supp1" => "NBS MP 277sup1",
    "NBS MP 278supp1" => "NBS MP 278sup1",
    "NIST SP 800-38b-2005" => "NIST SP 800-38Be2005",
  }.each do |input, expected|
    it "renders #{input.inspect} as #{expected.inspect}" do
      expect(Pubid::Nist.parse(input).to_s).to eq(expected)
    end
  end

  # Machine-readable (MR) form must also keep distinct documents distinct.
  # (The crawler uses the human form, but MR is exercised when an id is parsed
  # from its dotted form, so guard it too.)
  describe "machine-readable form distinctness" do
    {
      "Report parts" => %w[NBS.RPT.9981p1 NBS.RPT.9981p7],
      "FIPS update" => ["NIST.FIPS.197", "NIST.FIPS.197-upd1"],
      "Monograph parts" => ["NBS.MONO.128", "NBS.MONO.128pt1"],
    }.each do |label, inputs|
      it "#{label}: renders distinct MR ids" do
        ids = inputs.map { |s| Pubid::Nist.parse(s).to_s(:mr) }
        expect(ids.uniq.length).to eq(ids.length),
                                   "MR collision: #{inputs.inspect} => #{ids.inspect}"
      end
    end
  end
end
