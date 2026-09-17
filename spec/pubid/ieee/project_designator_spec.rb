# frozen_string: true

require "spec_helper"

# pubid#18: the ability to generate the IEEE PROJECT DESIGNATOR — the short
# "P<number>[/D<draft>]" form IEEE itself uses for draft documents — instead
# of the full "IEEE Draft Std …" rendering. metanorma-ieee post-processed
# the full rendering for this until now.
#
# The DEFAULT rendering keeps its current behavior (the corpus carries the P
# in every unapproved-draft canonical); :project is an ADDITIONAL format.
# The issue also reports that a bare "P1201/D0.3" parse dropped the P
# entirely — the grammar now lets :number capture it so code.prefix
# survives.
RSpec.describe "IEEE project designator rendering — issue #18" do
  subject(:klass) { Pubid::Ieee::Identifier }

  {
    "P1201/D0.3" => "P1201/D0.3",
    "IEEE Draft Std P10000-2025/D1.2" => "P10000/D1.2",
    "IEEE P802.16/D-3" => "P802.16/D3",
    "IEEE Unapproved Draft Std P802.3" => "P802.3/D1",
  }.each do |input, designator|
    context input.inspect do
      it "renders the designator #{designator.inspect} under format: :project" do
        expect(klass.parse(input).to_s(format: :project)).to eq(designator)
      end

      it "keeps the full rendering under the default format" do
        expect(klass.parse(input).to_s).not_to be_empty
      end
    end
  end

  it "preserves the project marker of a bare P spelling (no data loss)" do
    expect(klass.parse("P1201/D0.3").code_obj.prefix).to eq("P")
  end

  it "round-trips a bare P spelling through to_hash/from_hash" do
    id = klass.parse("P1201/D0.3")
    hash = id.to_hash
    expect(klass.from_hash(hash).to_hash).to eq(hash)
  end
end
