# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/cie/scheme"

RSpec.describe PubidNew::Cie::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(PubidNew::Cie::Scheme.identifiers).to be_an(Array)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::Standard)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::Conference)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::Bundle)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::DualPublished)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::Identical)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::JointPublished)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::Supplement)
      expect(PubidNew::Cie::Scheme.identifiers).to include(PubidNew::Cie::Identifiers::TutorialBundle)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of registered supplement identifier classes" do
      expect(PubidNew::Cie::Scheme.supplement_identifiers).to be_an(Array)
      expect(PubidNew::Cie::Scheme.supplement_identifiers).to include(PubidNew::Cie::Identifiers::Corrigendum)
    end
  end
end
