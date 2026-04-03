# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ashrae::Identifiers::AddendaPackage do
  # Basic smoke test for identifier class
  # TODO: Add comprehensive tests for parsing, rendering, and attributes

  it "is defined" do
    expect(described_class).to be_a(Class)
  end
end
