# frozen_string_literal: true

require "spec_helper"

# PNW is IEC's "new work item proposal" stage, harmonized code 10.20 — the
# spelling IEC's own portal uses, and the one pubid-iec 1.x carried in
# `stages.yaml` (`PNW: ["10.20"]`). pubid 2 had listed PNW as an alias of PWI,
# the preliminary-work-item stage (00.*), so `IEC PNW 1000-1:2023 ED2` rendered
# back as `IEC/PWI 1000-1:2023 ED2` — the wrong stage and the wrong separator.
#
# See https://github.com/pubid/pubid/issues/360 items 1 and 2.
RSpec.describe "IEC PNW stage" do
  describe "the registry" do
    let(:stages) { Pubid::Iec.all_typed_stages }

    it "gives PNW its own typed stage at 10.20" do
      pnw = stages.find { |s| s.code.to_s == "pnw" }

      expect(pnw).not_to be_nil
      expect(pnw.abbr.map(&:to_s)).to eq(["PNW"])
      expect(pnw.harmonized_stages.map(&:to_s)).to eq(["10.20"])
    end

    it "no longer lists PNW as a preliminary work item" do
      pwi = stages.find { |s| s.code.to_s == "pwi" }

      expect(pwi.abbr.map(&:to_s)).to include("PWI", "NWIP", "BWG", "AWIN")
      expect(pwi.abbr.map(&:to_s)).not_to include("PNW")
    end

    # 10.20 belongs to PNW alone, so a lookup by harmonized code is
    # unambiguous once the URN generator starts reading it.
    it "no longer lists 10.20 under the new-proposal stage" do
      np = stages.find { |s| s.code.to_s == "np" }

      expect(np.harmonized_stages.map(&:to_s)).not_to include("10.20")
    end

    it "resolves the PNW abbreviation to the PNW stage" do
      expect(Pubid::Iec.locate_stage("PNW").code.to_s).to eq("pnw")
    end

    # The URN generator writes `stage-{harmonized_stages.first}` and the URN
    # parser reads it back by searching for a stage with that type code and
    # that leading harmonized code. That inverse only exists while the pair is
    # unique. Eight other classes still carry "10.20" inside their own
    # new-proposal buckets — harmlessly, because it is not first — so the
    # invariant is a property of ORDERING, and this example is what keeps a
    # reordering from silently reopening the ambiguity.
    it "identifies a stage uniquely by its type and leading harmonized code" do
      collisions = stages
        .group_by { |s| [s.type_code.to_s, s.harmonized_stages&.first.to_s] }
        .select { |_, group| group.size > 1 }

      shown = collisions.transform_values { |g| g.map { |s| s.code.to_s } }

      expect(collisions).to be_empty,
                            "these stages share a (type, harmonized) key: " \
                            "#{shown.inspect}"
    end
  end

  describe "a standards-track identifier with a PNW stage" do
    subject(:id) { Pubid::Iec.parse("IEC PNW 1000-1:2023 ED2") }

    it "renders the identifier as it was written" do
      expect(id.to_s).to eq("IEC PNW 1000-1:2023 ED2")
    end

    it "carries the PNW typed stage" do
      expect(id.typed_stage.code.to_s).to eq("pnw")
      expect(id.typed_stage.harmonized_stages.map(&:to_s)).to eq(["10.20"])
    end

    it "renders as a fixed point" do
      expect(Pubid::Iec.parse(id.to_s).to_s).to eq(id.to_s)
    end
  end

  # The bare forms are IEC work-programme registrations, not documents: their
  # numbers are TC-scoped (`86B-15`, `SyCCOMM-1`), not IEC document numbers. So
  # they stay `WorkingDocument` and keep rendering bare. Adding an `IEC `
  # prefix would also break idempotence, because `IEC PNW 65-915 ED1` re-parses
  # as an International Standard.
  describe "bare working-programme forms" do
    {
      "PNW 65-915 ED1" => "pnw",
      "PNW 3D-376 ED1" => "pnw",
      "PNW TS SYCLVDC-125 ED1" => "pnw",
      "PWI 100-44 ED1" => "pwi",
      "PWI 86B-15 ED1" => "pwi",
    }.each do |input, stage_code|
      it "renders #{input.inspect} unchanged, with the #{stage_code} stage" do
        id = Pubid::Iec.parse(input)

        expect(id).to be_a(Pubid::Iec::Identifiers::WorkingDocument)
        expect(id.to_s).to eq(input)
        expect(id.stage.stage_code.to_s).to eq(stage_code)
      end
    end

    it "gives a PNW work programme the 10.20 harmonized code" do
      id = Pubid::Iec.parse("PNW 65-915 ED1")

      expect(id.stage.harmonized_stages.map(&:to_s)).to eq(["10.20"])
    end
  end
end
