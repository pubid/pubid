# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Supplement with nil typed_stage" do
  # A supplement segment without a stage is malformed per ISO DIR
  # composition (pubid#680): the renderer must fail loudly instead of
  # emitting a bare "/" (metanorma-iso's draft-biblio flow, the historic
  # nil producer, now stops stripping the stage — metanorma-iso#1696).
  it "raises ArgumentError naming the identifier" do
    id = Pubid::Iso::Identifier.parse("ISO 32000-2:2020/DAM 1")
    id.typed_stage = nil if id.respond_to?(:typed_stage=)
    expect { id.to_s }.to raise_error(ArgumentError, /typed_stage.*32000-2/m)
  end
end
