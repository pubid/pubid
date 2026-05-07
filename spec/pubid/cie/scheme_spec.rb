# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/cie/scheme"

RSpec.describe Pubid::Cie::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::Standard)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::Conference)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::Bundle)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::DualPublished)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::Identical)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::JointPublished)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::Supplement)
      expect(described_class.identifiers).to include(Pubid::Cie::Identifiers::TutorialBundle)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of registered supplement identifier classes" do
      expect(described_class.supplement_identifiers).to be_an(Array)
      expect(described_class.supplement_identifiers).to include(Pubid::Cie::Identifiers::Corrigendum)
    end
  end
end
