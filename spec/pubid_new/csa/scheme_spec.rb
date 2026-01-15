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
end
