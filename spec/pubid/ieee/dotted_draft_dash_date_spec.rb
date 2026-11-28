# frozen_string_literal: true

require "spec_helper"

# relaton's fallback renderer writes a draft as "/D-<version>" followed by the
# document's dash date ("IEEE P1547/D-6.7.2-2017-05"). The grammar splits a
# dotted version into one element per segment ("-6", ".7.2"); the builder
# embedded the joined version and the date on the first element but left the
# trailing segment on the second, so the version read "6.7.2-2017-05.7.2".
# relaton stored that rendering as the primary docidentifier, and pubid could
# not parse it back: 20 rows of relaton/relaton-data-ieee#10.
RSpec.describe "IEEE dotted draft with a relaton dash date" do
  subject(:klass) { Pubid::Ieee::Identifier }

  {
    "IEEE P1547/D-6.7.2-2017-05" => "IEEE P1547/D6.7.2-2017-05",
    "IEEE P1547/D-6.7-2017-05" => "IEEE P1547/D6.7-2017-05",
    "IEEE P802.22/D-6.0.0-2019-05" => "IEEE P802.22/D6.0.0-2019-05",
    "IEEE P1901.2/D-0.09.00-2013-06" => "IEEE P1901.2/D0.09.00-2013-06",
    "IEEE P1547/D-6-2017-05" => "IEEE P1547/D6-2017-05",
  }.each do |ref, rendered|
    context ref.inspect do
      let(:id) { klass.parse(ref) }

      it "renders the draft once, with no repeated tail" do
        expect(id.to_s).to eq(rendered)
      end

      it "keeps the date out of a second copy of the version" do
        expect(id.to_hash["draft"]).to eq(rendered.split("/").last)
      end

      it "is equal after from_hash(to_hash)" do
        expect(klass.from_hash(id.to_hash)).to eq(id)
      end
    end
  end

  # A year-only dash tail beside a base year, and a numeric-month draft
  # date, go through two other builder branches with the same embed.
  {
    "IEEE Std 1547-2011/D-6.7.2-2017" => "IEEE Draft 1547/D6.7.2-2017, 2011",
    "IEEE P1547/D-6.7.2, 05 2017" => "IEEE P1547/D6.7.2-2017-05",
  }.each do |ref, rendered|
    it "renders #{ref.inspect} without a repeated tail" do
      expect(klass.parse(ref).to_s).to eq(rendered)
    end
  end

  # The canonical no-dash rendering parses back to the same identifier: the
  # vendored grammar captures the dotted triple inside
  # draft_version_composite (pubid-grammar, relaton-data-ieee#10).
  it "parses its own rendering back to the same identifier" do
    id = klass.parse("IEEE P1547/D-6.7.2-2017-05")
    expect(klass.parse(id.to_s).to_hash).to eq(id.to_hash)
  end

  # Before that grammar fix the triple fell outside the capture, so the
  # draft was dropped ("IEEE P1547") or cut to its first segment
  # ("IEEE Unapproved P754/D1").
  {
    "IEEE P1547/D6.7.2-2017-05" => "IEEE P1547/D6.7.2-2017-05",
    "IEEE Std P754/D1.2.6" => "IEEE Draft P754/D1.2.6",
    "IEEE P1547/D6.7.2, May 2017" => "IEEE P1547/D6.7.2, May, 2017",
    "IEEE P11073-10201/D2.1.10 October 2018" =>
      "IEEE P11073-10201/D2.1.10 Oct 2018",
    "IEEE Unapproved Draft Std P754/D1.4.0, Apr 2007" =>
      "IEEE Unapproved P754/D1.4.0, Apr 2007",
  }.each do |ref, rendered|
    context "the triple draft #{ref.inspect}" do
      let(:id) { klass.parse(ref) }

      it "keeps the whole version" do
        expect(id.to_s).to eq(rendered)
      end

      it "parses its rendering back to the same identifier" do
        expect(klass.parse(id.to_s).to_hash).to eq(id.to_hash)
      end

      it "is equal after from_hash(to_hash)" do
        expect(klass.from_hash(id.to_hash)).to eq(id)
      end
    end
  end
end
