# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/oiml/scheme"

RSpec.describe PubidNew::Oiml::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(PubidNew::Oiml::Scheme.identifiers).to be_an(Array)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::BasicPublication)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::Document)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::ExpertReport)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::Guide)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::Recommendation)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::SeminarReport)
      expect(PubidNew::Oiml::Scheme.identifiers).to include(PubidNew::Oiml::Identifiers::Vocabulary)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of registered supplement identifier classes" do
      expect(PubidNew::Oiml::Scheme.supplement_identifiers).to be_an(Array)
      expect(PubidNew::Oiml::Scheme.supplement_identifiers).to include(PubidNew::Oiml::Identifiers::Amendment)
      expect(PubidNew::Oiml::Scheme.supplement_identifiers).to include(PubidNew::Oiml::Identifiers::Annex)
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "raises error indicating OIML does not use typed stages" do
      expect { described_class.locate_typed_stage_by_abbr("anything") }
        .to raise_error(ArgumentError, /OIML identifiers do not use typed stages/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "raises error indicating OIML does not use type codes" do
      expect { described_class.locate_identifier_klass_by_type_code("anything") }
        .to raise_error(ArgumentError, /OIML identifiers do not use type codes/)
    end
  end
end
