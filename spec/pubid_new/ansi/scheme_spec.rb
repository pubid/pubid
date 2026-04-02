# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ansi do
  describe "::Scheme" do
    it "is a Pubid::Scheme instance" do
      expect(described_class::Scheme).to be_a(Pubid::Scheme)
    end
  end

  describe "::IDENTIFIER_TYPES" do
    it "defines registered identifier types" do
      expect(described_class::IDENTIFIER_TYPES).to be_an(Array)
      expect(described_class::IDENTIFIER_TYPES).to include(Pubid::Ansi::Identifiers::Standard)
    end
  end
end
