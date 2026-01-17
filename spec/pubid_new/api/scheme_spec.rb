# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Api::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(PubidNew::Api::Identifiers::Standard)
      expect(described_class.identifiers).to include(PubidNew::Api::Identifiers::RecommendedPractice)
    end

    it "includes all expected identifier types" do
      expected_classes = [
        PubidNew::Api::Identifiers::Standard,
        PubidNew::Api::Identifiers::RecommendedPractice,
        PubidNew::Api::Identifiers::Specification,
        PubidNew::Api::Identifiers::TechnicalReport,
        PubidNew::Api::Identifiers::Bulletin,
        PubidNew::Api::Identifiers::Mpms,
        PubidNew::Api::Identifiers::ContinuousOperationsStandard,
        PubidNew::Api::Identifiers::Publication,
        PubidNew::Api::Identifiers::TypelessStandard,
      ]
      expected_classes.each do |klass|
        expect(described_class.identifiers).to include(klass)
      end
    end
  end

  # TODO: Add typed_stages tests when API identifiers have TYPED_STAGES
  # For now, API uses type_string methods instead of TYPED_STAGES pattern
end
