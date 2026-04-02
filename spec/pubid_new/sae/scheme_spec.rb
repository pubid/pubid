# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Sae::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(PubidNew::Sae::Identifiers::Base)
    end

    it "includes Base identifier" do
      expect(described_class.identifiers).to include(PubidNew::Sae::Identifiers::Base)
    end
  end

  # TODO: Add typed_stages tests when SAE identifiers have TYPED_STAGES
  # For now, SAE uses Sae::Components::Type instead of TYPED_STAGES pattern
end
