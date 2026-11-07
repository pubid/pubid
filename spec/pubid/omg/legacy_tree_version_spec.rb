# frozen_string_literal: true

require "spec_helper"

# The legacy named-tree version emission (Pubid::LegacyTreeValue) reached
# relaton-data-omg too: five beta documents deserialize with
# `version: '[{digit: "2"}]'` where the document's version is "1.0 beta 2".
# The emission drops every unnamed literal, and in the OMG grammar's version
# rule only the beta tail's `digit` nodes are named — so the version body is
# unrecoverable and the one faithful recovery is the digits themselves.
# Rendered verbatim the row printed the node hashes ("OMG DPROD [{digit:
# \"2\"}]", the relaton corpus gate's omg-fidelity failures).
RSpec.describe "Pubid::Omg legacy named-tree version emission" do
  it "assembles the single-node emission to the digit" do
    id = Pubid::Omg::Identifier.from_hash(
      { "_type" => "pubid:omg:specification", "acronym" => "DPROD",
        "version" => '[{digit: "2"}]' },
    )
    expect(id.version).to eq("2")
    expect(id.to_s).to eq("OMG DPROD 2")
  end

  it "joins a multi-node emission" do
    id = Pubid::Omg::Identifier.from_hash(
      { "_type" => "pubid:omg:specification", "acronym" => "FACEv2",
        "version" => '[{digit: "2"}, {digit: "0"}]' },
    )
    expect(id.version).to eq("20")
  end

  it "assembles a real array of digit nodes" do
    id = Pubid::Omg::Identifier.from_hash(
      { "_type" => "pubid:omg:specification", "acronym" => "MDMI",
        "version" => [{ "digit" => "2" }] },
    )
    expect(id.version).to eq("2")
  end

  it "assembled print re-parses to the same structure (Law 1b)" do
    id = Pubid::Omg::Identifier.from_hash(
      { "_type" => "pubid:omg:specification", "acronym" => "Essence",
        "version" => '[{digit: "2"}]' },
    )
    parsed = Pubid::Omg::Identifier.parse(id.to_s)
    expect(parsed.to_s).to eq(id.to_s)
    expect(parsed.to_hash).to eq(id.to_hash)
  end

  it "leaves plain version scalars untouched" do
    id = Pubid::Omg::Identifier.from_hash(
      { "_type" => "pubid:omg:specification", "acronym" => "UML",
        "version" => "2.5.1" },
    )
    expect(id.version).to eq("2.5.1")
  end

  it "leaves the beta-label version scalars untouched" do
    id = Pubid::Omg::Identifier.from_hash(
      { "_type" => "pubid:omg:specification", "acronym" => "UTP2",
        "version" => "2.3 beta" },
    )
    expect(id.version).to eq("2.3 beta")
  end
end
