# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/cie/scheme"

RSpec.describe Pubid::Cie::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(Pubid::Cie::Scheme.identifiers).to be_an(Array)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::Standard)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::Conference)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::Bundle)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::DualPublished)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::Identical)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::JointPublished)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::Supplement)
      expect(Pubid::Cie::Scheme.identifiers).to include(Pubid::Cie::Identifiers::TutorialBundle)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of registered supplement identifier classes" do
      expect(Pubid::Cie::Scheme.supplement_identifiers).to be_an(Array)
      expect(Pubid::Cie::Scheme.supplement_identifiers).to include(Pubid::Cie::Identifiers::Corrigendum)
    end
  end
end
