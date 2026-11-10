# frozen_string_literal: true

require "spec_helper"

# `original_abbr` records how the input spelled the typed stage ("Amd." or
# "AMD"). It is spelling, not identity (issue #656), so `==`, `eql?`, `hash`
# and `===` skip it.
RSpec.describe Pubid::Components::TypedStage do
  def typed_stage(original_abbr)
    described_class.new(name: "Amendment", type_code: "amd",
                        stage_code: "published", abbr: ["Amd"],
                        original_abbr: original_abbr)
  end

  let(:dotted) { typed_stage("Amd.") }
  let(:plain) { typed_stage("Amd") }

  it "is == when only original_abbr differs" do
    expect(dotted).to eq(plain)
    expect(dotted).to eql(plain)
  end

  it "has the same hash when only original_abbr differs" do
    expect(dotted.hash).to eq(plain.hash)
  end

  it "is === in both directions when only original_abbr differs" do
    expect(dotted === plain).to be(true)
    expect(plain === dotted).to be(true)
  end

  it "is not == when the stage differs" do
    other = described_class.new(name: "Amendment", type_code: "amd",
                                stage_code: "draft", abbr: ["Amd"],
                                original_abbr: "Amd")
    expect(plain).not_to eq(other)
  end
end
