# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Ansi do
  describe "::Scheme" do
    it "is a PubidNew::Scheme instance" do
      expect(described_class::Scheme).to be_a(PubidNew::Scheme)
    end
  end

  describe "::IDENTIFIER_TYPES" do
    it "defines registered identifier types" do
      expect(described_class::IDENTIFIER_TYPES).to be_an(Array)
      expect(described_class::IDENTIFIER_TYPES).to include(PubidNew::Ansi::Identifiers::Standard)
    end
  end
end
