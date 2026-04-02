# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/pubid/cie/identifiers/dual_published"

RSpec.describe Pubid::Cie::Identifiers::DualPublished do
  # Basic smoke test for identifier class
  # TODO: Add comprehensive tests for parsing, rendering, and attributes

  it "is defined" do
    expect(described_class).to be_a(Class)
  end
end
