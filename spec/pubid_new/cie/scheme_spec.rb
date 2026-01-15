# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/cie/scheme"

RSpec.describe PubidNew::Cie::Scheme do
  describe "#identifiers" do
    it "returns array of registered identifier classes" do
      scheme = PubidNew::Cie::Scheme.new
      expect(scheme.identifiers).to be_an(Array)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Standard)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Conference)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Corrigendum)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Bundle)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::DualPublished)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Identical)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::JointPublished)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Supplement)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::TutorialBundle)
    end
  end
end
