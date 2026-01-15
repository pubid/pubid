# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/astm/scheme"

RSpec.describe PubidNew::Astm::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(PubidNew::Astm::Scheme.identifiers).to be_an(Array)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::Standard)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::Manual)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::ResearchReport)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::DataSeries)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::TechnicalReport)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::Monograph)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::Adjunct)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::WorkInProgress)
      expect(PubidNew::Astm::Scheme.identifiers).to include(PubidNew::Astm::Identifiers::IsoDualPublished)
    end
  end
end
