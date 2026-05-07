# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/astm/scheme"

RSpec.describe Pubid::Astm::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::Standard)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::Manual)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::ResearchReport)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::DataSeries)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::TechnicalReport)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::Monograph)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::Adjunct)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::WorkInProgress)
      expect(described_class.identifiers).to include(Pubid::Astm::Identifiers::IsoDualPublished)
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "raises error indicating ASTM does not use typed stages" do
      expect { described_class.locate_typed_stage_by_abbr("anything") }
        .to raise_error(ArgumentError,
                        /ASTM identifiers do not use typed stages/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "raises error indicating ASTM does not use type codes" do
      expect do
        described_class.locate_identifier_klass_by_type_code("anything")
      end
        .to raise_error(ArgumentError, /ASTM identifiers do not use type codes/)
    end
  end
end
