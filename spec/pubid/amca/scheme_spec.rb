# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Amca::Scheme do
  describe "initialization" do
    it "creates a new scheme instance" do
      scheme = described_class.new
      expect(scheme).to be_a(described_class)
      expect(scheme).to be_a(Pubid::Scheme)
    end
  end

  describe "#identifiers" do
    it "returns frozen array of identifier classes" do
      scheme = described_class.new
      expect(scheme.identifiers).to be_an(Array)
      expect(scheme.identifiers).to all(be_a(Class))
      expect(scheme.identifiers).to include(Pubid::Amca::Identifiers::Standard)
      expect(scheme.identifiers).to include(Pubid::Amca::Identifiers::Publication)
      expect(scheme.identifiers).to include(Pubid::Amca::Identifiers::Interpretation)
      expect(scheme.identifiers).to be_frozen
    end
  end

  it "inherits from Pubid::Scheme" do
    expect(described_class).to be < Pubid::Scheme
  end

  # TODO: Add typed_stages tests when AMCA identifiers have TYPED_STAGES
  # For now, AMCA uses Pubid::Scheme base class with instance methods
end
