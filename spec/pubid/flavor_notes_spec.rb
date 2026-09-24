# frozen_string_literal: true

require "spec_helper"

# Each flavor's own forensics live in lib/pubid/<flavor>/CLAUDE.md, next to that
# flavor's code. Claude Code auto-loads a directory's CLAUDE.md when working with
# files in it, so there is no index to keep in step (unlike the old
# docs/flavors/<flavor>.md + root-CLAUDE.md-index layout this replaced) — a file's
# path already proves it lives under lib/pubid.
RSpec.describe "Flavor notes" do
  let(:repo_root) { File.expand_path("../..", __dir__) }
  let(:claude_md) { File.join(repo_root, "CLAUDE.md") }
  let(:flavor_note_files) { Dir[File.join(repo_root, "lib", "pubid", "*", "CLAUDE.md")].sort }

  it "has at least one flavor-local CLAUDE.md under lib/pubid" do
    expect(flavor_note_files).not_to be_empty
  end

  it "writes a non-empty note for every flavor" do
    too_small = flavor_note_files.select { |file| File.size(file) < 200 }
    expect(too_small).to be_empty
  end

  it "does not keep a legacy docs/flavors directory" do
    expect(Dir.exist?(File.join(repo_root, "docs", "flavors"))).to be(false)
  end

  it "keeps the root CLAUDE.md small enough to load in every session" do
    # The split exists to bound this file. 100 KB leaves room to grow while
    # still catching a flavor bullet appended to the root file by mistake.
    # Measured LF-normalized: a Windows CRLF checkout inflates every byte
    # count by one per line, which flipped this budget red on windows-latest
    # while the file was under the cap on LF (the content did not change).
    size = File.read(claude_md).delete("\r").bytesize
    expect(size).to be < 100_000
  end
end
