# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/asme/scheme"

RSpec.describe PubidNew::Asme::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(PubidNew::Asme::Scheme.identifiers).to be_an(Array)
      expect(PubidNew::Asme::Scheme.identifiers).to include(PubidNew::Asme::Identifiers::Standard)
    end
  end
end
