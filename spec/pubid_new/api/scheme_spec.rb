# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Api::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(Pubid::Api::Identifiers::Standard)
      expect(described_class.identifiers).to include(Pubid::Api::Identifiers::RecommendedPractice)
    end

    it "includes all expected identifier types" do
      expected_classes = [
        Pubid::Api::Identifiers::Standard,
        Pubid::Api::Identifiers::RecommendedPractice,
        Pubid::Api::Identifiers::Specification,
        Pubid::Api::Identifiers::TechnicalReport,
        Pubid::Api::Identifiers::Bulletin,
        Pubid::Api::Identifiers::Mpms,
        Pubid::Api::Identifiers::ContinuousOperationsStandard,
        Pubid::Api::Identifiers::Publication,
        Pubid::Api::Identifiers::TypelessStandard,
      ]
      expected_classes.each do |klass|
        expect(described_class.identifiers).to include(klass)
      end
    end
  end

  # TODO: Add typed_stages tests when API identifiers have TYPED_STAGES
  # For now, API uses type_string methods instead of TYPED_STAGES pattern
end
