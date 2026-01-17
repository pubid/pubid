# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Amca::Scheme do
  describe "initialization" do
    it "creates a new scheme instance" do
      scheme = described_class.new
      expect(scheme).to be_a(PubidNew::Amca::Scheme)
      expect(scheme).to be_a(PubidNew::Scheme)
    end
  end

  describe "#identifiers" do
    it "returns frozen array of identifier classes" do
      scheme = described_class.new
      expect(scheme.identifiers).to be_an(Array)
      expect(scheme.identifiers).to all(be_a(Class))
      expect(scheme.identifiers).to include(PubidNew::Amca::Identifiers::Standard)
      expect(scheme.identifiers).to include(PubidNew::Amca::Identifiers::Publication)
      expect(scheme.identifiers).to include(PubidNew::Amca::Identifiers::Interpretation)
      expect(scheme.identifiers).to be_frozen
    end
  end

  it "inherits from PubidNew::Scheme" do
    expect(described_class).to be < PubidNew::Scheme
  end

  # TODO: Add typed_stages tests when AMCA identifiers have TYPED_STAGES
  # For now, AMCA uses PubidNew::Scheme base class with instance methods
end
