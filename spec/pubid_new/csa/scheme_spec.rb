# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/csa/scheme"

RSpec.describe PubidNew::Csa::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(PubidNew::Csa::Scheme.identifiers).to be_an(Array)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::Standard)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::Bundled)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::CanadianAdopted)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::CsaAdopted)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::Package)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::Series)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::Cec)
      expect(PubidNew::Csa::Scheme.identifiers).to include(PubidNew::Csa::Identifiers::Combined)
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "raises error indicating CSA does not use typed stages" do
      expect { described_class.locate_typed_stage_by_abbr("anything") }
        .to raise_error(ArgumentError, /CSA identifiers do not use typed stages/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "raises error indicating CSA does not use type codes" do
      expect { described_class.locate_identifier_klass_by_type_code("anything") }
        .to raise_error(ArgumentError, /CSA identifiers do not use type codes/)
    end
  end
end
