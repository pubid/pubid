# frozen_string_literal: true

require "spec_helper"
require "parsanol"

# data/parg/jis.json is vendored verbatim from pubid/pubid-grammar
# (artifacts/jis.json), the JIS grammar of record. The grammar binds the
# reaffirmation marker as the whole run of R's: "R" for ":1997R", "RR" for
# ":1997RR". In pubid-grammar before 31fb965 the capture took only the
# repeated R's (":1997R" bound []); pubid's earlier local bake did not carry
# that defect, so only the source_hash pin tells the two artifacts apart.
RSpec.describe "JIS PARG artifact: reaffirmed capture" do
  def bound(input)
    Pubid::Parg::Model.bound(:jis, input)
  end

  it "is the pubid-grammar bake, not a local one" do
    artifact = Parsanol::PARG::Artifact.load(
      Pubid::Parg::Artifact.path_for(:jis),
    )

    # pubid-grammar main 31fb965, parsanol 1.3.121. A local rebake changes
    # this hash; re-vendor from pubid-grammar instead.
    expect(artifact.source_hash)
      .to eq("bb68f75e3e1d9b7e79613bd6cff60ccd77f6e2e68ace2569a2fbc968543b1f3d")
  end

  {
    "JIS X 0208:1997R" => "R",
    "JIS X 0208:1997RR" => "RR",
    "WES 7301:2020R" => "R",
  }.each do |input, run|
    it "binds reaffirmed: #{run.inspect} for #{input}" do
      expect(bound(input)[:reaffirmed]).to eq(run)
    end
  end

  it "binds no reaffirmed key for an unmarked year" do
    expect(bound("JIS X 0208:1997")).not_to have_key(:reaffirmed)
  end

  it "binds amd_reaffirmed for a reaffirmed amendment" do
    expect(bound("JIS X 0208:1997/AMD 1:2020R")[:amd_reaffirmed]).to eq("R")
  end

  it "builds a reaffirmed identifier from the whole run" do
    id = Pubid::Jis.parse("JIS X 0208:1997R")

    expect(id).to be_reaffirmed
    expect(id.to_s).to eq("JIS X 0208:1997R")
  end
end
