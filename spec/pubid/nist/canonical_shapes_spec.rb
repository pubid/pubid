# frozen_string_literal: true

require "spec_helper"

# pubid/pubid-testsuite#5 (C4/C5): three NIST canonical-shape rulings.
RSpec.describe "NIST canonical shapes (C4/C5)" do
  describe "series-only supplement" do
    it "keeps the .sup marker in the series-only form" do
      id = Pubid::Nist.parse("NBS.CIRC.sup")
      expect(id.to_s).to eq("NBS.CIRC.sup")
      expect(id.supplement).not_to be_nil
    end
  end

  describe "dotted edition" do
    it "renders the series-only edition with its dot separator" do
      expect(Pubid::Nist.parse("NBS.CIRC.e2").to_s).to eq("NBS.CIRC.e2")
    end

    it "keeps the numbered form glued per the NIST spec" do
      expect(Pubid::Nist.parse("NIST SP 800-53r5").to_s).to eq("NIST SP 800-53r5")
      expect(Pubid::Nist.parse("NIST SP 800-53r5").to_s(:mr)).to eq("NIST.SP.800-53r5")
    end
  end

  describe "revision folding asymmetry" do
    it "keeps the revision in the mr form (ruled: intended)" do
      expect(Pubid::Nist.parse("NBS.CIRC.154suprev").to_s).to eq("NBS.CIRC.154suprev")
    end

    it "folds the revision in the short form (ruled: intended)" do
      expect(Pubid::Nist.parse("NBS CIRC 154suprev").to_s).to eq("NBS CIRC 154sup")
    end
  end
end
