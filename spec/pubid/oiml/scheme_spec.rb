# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/oiml/scheme"

RSpec.describe Pubid::Oiml::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(Pubid::Oiml::Scheme.identifiers).to be_an(Array)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::BasicPublication)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::Document)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::ExpertReport)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::Guide)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::Recommendation)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::SeminarReport)
      expect(Pubid::Oiml::Scheme.identifiers).to include(Pubid::Oiml::Identifiers::Vocabulary)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of registered supplement identifier classes" do
      expect(Pubid::Oiml::Scheme.supplement_identifiers).to be_an(Array)
      expect(Pubid::Oiml::Scheme.supplement_identifiers).to include(Pubid::Oiml::Identifiers::Amendment)
      expect(Pubid::Oiml::Scheme.supplement_identifiers).to include(Pubid::Oiml::Identifiers::Annex)
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "raises error indicating OIML does not use typed stages" do
      expect { described_class.locate_typed_stage_by_abbr("anything") }
        .to raise_error(ArgumentError,
                        /OIML identifiers do not use typed stages/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "raises error indicating OIML does not use type codes" do
      expect do
        described_class.locate_identifier_klass_by_type_code("anything")
      end
        .to raise_error(ArgumentError, /OIML identifiers do not use type codes/)
    end
  end
end
