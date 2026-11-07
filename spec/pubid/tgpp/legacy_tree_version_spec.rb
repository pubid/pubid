# frozen_string_literal: true

require "spec_helper"

# The legacy named-tree version emission (Pubid::LegacyTreeValue): the
# parsanol 1.3.111 edition-2 crawlers wrote ~89,000 relaton-data-3gpp rows
# with the parse tree's per-digit node list in place of the version — the
# unnamed "." literals never reached the stored row, so
# `version: '[{digit: "3"}, {digit: "0"}, {digit: "0"}]'` sits in the index
# where the document's version is `3.0.0`. Rendered verbatim the row printed
# the node hashes and the print never re-parsed (the relaton corpus gate's
# Law 1a; run 42204581379, ~22,000 NEW 3gpp fidelity failures).
#
# from_hash assembles the digits back into the three-segment version. The
# segmentation is validated against the index's own clean rows (the crawler
# wrote both forms per document): 89,223 pairs, 165 irrecoverable — identical
# digit tuples whose documents genuinely differ.
RSpec.describe "Pubid::Tgpp legacy named-tree version emission" do
  TYPE = "pubid:3gpp:technical-specification"

  def row(number:, version:, release: nil, type: TYPE)
    { "_type" => type, "number" => number, "version" => version }.tap do |hash|
      hash["release"] = release if release
    end
  end

  describe "the observed emission shapes" do
    it "assembles the Ruby-inspect emission with the release-pinned major" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "21.101", release: "REL-18",
            version: '[{digit: "1"}, {digit: "8"}, {digit: "1"}, {digit: "0"}]'),
      )
      expect(id.version).to eq("18.1.0")
      expect(id.to_s).to eq("TS 21.101:REL-18/18.1.0")
    end

    it "assembles the hash-rocket emission (a JSON hop)" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "00.01", release: "UMTS", type: "pubid:3gpp:technical-report",
            version: '[{"digit" => "3"}, {"digit" => "0"}, {"digit" => "0"}]'),
      )
      expect(id.version).to eq("3.0.0")
    end

    it "assembles a real array of digit nodes" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "00.01", release: "UMTS", type: "pubid:3gpp:technical-report",
            version: [{ "digit" => "3" }, { "digit" => "0" }, { "digit" => "0" }]),
      )
      expect(id.version).to eq("3.0.0")
    end
  end

  describe "release-pinned majors" do
    {
      "REL-18" => ["18.1.0", "18.0.1"],
      "REL-19" => ["19.0.0"],
      "REL-4" => ["4.1.2", "4.0.0"],
      "REL-99" => ["3.1.0", "3.14.0"],
      "REL-96" => ["5.0.0"],
      "REL-98" => ["7.1.0"],
      "UMTS" => ["3.0.0"],
      "Ph1" => ["3.0.1"],
      "Ph2" => ["4.2.0"],
    }.each do |release, versions|
      versions.each do |version|
        digits = version.delete(".")
        tree = "[{digit: \"#{digits.chars.join('"}, {digit: "')}\"}]"
        it "assembles #{release} #{tree} to #{version}" do
          id = Pubid::Tgpp::Identifier.from_hash(
            row(number: "21.101", release: release, version: tree),
          )
          expect(id.version).to eq(version)
        end
      end
    end

    it "does not pin a major the digits do not start with" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "21.101", release: "REL-18",
            version: '[{digit: "1"}, {digit: "1"}, {digit: "0"}, {digit: "0"}]'),
      )
      # (1,1,0,0) under REL-18: the pair "11" is a plausible major, the
      # release's "18" is not a prefix — the fallback decides, not the pin.
      expect(id.version).to eq("11.0.0")
    end
  end

  describe "the fallback segmentation (no usable release pin)" do
    {
      '[{digit: "3"}, {digit: "0"}, {digit: "0"}]' => "3.0.0",
      '[{digit: "0"}, {digit: "1"}, {digit: "0"}, {digit: "0"}]' => "0.10.0",
      '[{digit: "1"}, {digit: "8"}, {digit: "1"}, {digit: "0"}]' => "18.1.0",
      '[{digit: "8"}, {digit: "1"}, {digit: "0"}, {digit: "0"}]' => "8.10.0",
      '[{digit: "1"}, {digit: "8"}, {digit: "1"}, {digit: "1"}, {digit: "0"}]' => "18.1.10",
    }.each do |tree, version|
      it "assembles #{tree} to #{version}" do
        id = Pubid::Tgpp::Identifier.from_hash(row(number: "21.101", 
                                                   version: tree))
        expect(id.version).to eq(version)
      end
    end
  end

  describe "the assembled version round-trips" do
    it "render(parse(from_hash)) is the assembled print" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "00.01", release: "UMTS", type: "pubid:3gpp:technical-report",
            version: '[{digit: "3"}, {digit: "0"}, {digit: "0"}]'),
      )
      printed = id.to_s
      expect(Pubid::Tgpp::Identifier.parse(printed).to_s).to eq(printed)
      expect(Pubid::Tgpp::Identifier.parse(printed).to_hash).to eq(id.to_hash)
    end

    it "the unrecoverable residue still parses and round-trips" do
      # (1,1,0,0) means both 1.10.0 and 11.0.0 in the corpus; the fallback
      # picks one deterministically and it must re-parse to itself.
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "21.101", version:
          '[{digit: "1"}, {digit: "1"}, {digit: "0"}, {digit: "0"}]'),
      )
      printed = id.to_s
      expect(Pubid::Tgpp::Identifier.parse(printed).to_hash).to eq(id.to_hash)
    end
  end

  describe "non-emission values pass through untouched" do
    it "keeps a plain version scalar" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "00.01", release: "UMTS", type: "pubid:3gpp:technical-report",
            version: "3.0.0"),
      )
      expect(id.version).to eq("3.0.0")
    end

    it "keeps a version-shaped string that merely looks like a list" do
      id = Pubid::Tgpp::Identifier.from_hash(
        row(number: "00.01", version: "[{digit: X}]"),
      )
      expect(id.version).to eq("[{digit: X}]")
    end

    it "keeps a nil version" do
      id = Pubid::Tgpp::Identifier.from_hash(row(number: "00.01", version: nil))
      expect(id.version).to be_nil
    end
  end
end
