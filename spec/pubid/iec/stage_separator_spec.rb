# frozen_string_literal: true

require "spec_helper"

# IEC house style puts a space, not a slash, between the publisher and the
# typed-stage abbreviation: "IEC PNW 1000-1:2023", not "IEC/PNW 1000-1:2023".
# pubid-iec 1.x rendered a space for every type and rejected the slash form
# outright. pubid 2 rendered a slash for International Standards, amendments,
# corrigenda and interpretation sheets, while about a dozen per-type classes
# overrode the base to force a space — so the flavor disagreed with itself.
#
# Both spellings stay ACCEPTED on input. Only rendering normalises.
#
# See https://github.com/pubid/pubid/issues/360 item 2.
RSpec.describe "IEC stage separator" do
  describe "rendering" do
    {
      "IEC/CD 60038" => "IEC CD 60038",
      "IEC CD 60038" => "IEC CD 60038",
      "IEC/CDV 60038" => "IEC CDV 60038",
      "IEC/FDIS 60038" => "IEC FDIS 60038",
      "IEC/NP 60038" => "IEC NP 60038",
      "IEC/DISH 60050-191" => "IEC DISH 60050-191",
      "IEC/FDAM 60038-1" => "IEC FDAM 60038-1",
      "IEC/DCOR 60038-1" => "IEC DCOR 60038-1",
      # Already rendered with a space by a per-type override; must not move.
      "IEC TS 60038" => "IEC TS 60038",
      "IEC/DTR 62048" => "IEC DTR 62048",
      # A copublisher list keeps its slashes; only the stage separator changes.
      "ISO/IEC 27001" => "ISO/IEC 27001",
      "IEC/IEEE 82079-1" => "IEC/IEEE 82079-1",
    }.each do |input, expected|
      it "renders #{input.inspect} as #{expected.inspect}" do
        expect(Pubid::Iec.parse(input).to_s).to eq(expected)
      end
    end
  end

  describe "input acceptance" do
    [
      %w[IEC/CD\ 60038 IEC\ CD\ 60038],
      ["IEC/FDIS 60038", "IEC FDIS 60038"],
      ["IEC/FDAM 60038-1", "IEC FDAM 60038-1"],
    ].each do |slash, space|
      it "parses #{slash.inspect} and #{space.inspect} alike" do
        from_slash = Pubid::Iec.parse(slash)
        from_space = Pubid::Iec.parse(space)

        expect(from_slash.to_s).to eq(from_space.to_s)
        expect(from_slash.to_hash).to eq(from_space.to_hash)
      end
    end
  end

  # The PAS override built its prefix from `publisher.to_s` with no copublisher
  # handling and no `super`, so a copublished PAS lost the IEC half from both
  # the printed form and the URN. Deleting the override repairs it.
  describe "copublished documents keep every publisher" do
    it "keeps IEC on a copublished PAS" do
      id = Pubid::Iec.parse("ISO/IEC PAS 62975")

      expect(id.to_s).to eq("ISO/IEC PAS 62975")
      expect(id.to_urn).to include("iso-iec")
    end
  end

  it "renders every stage form as a fixed point" do
    inputs = ["IEC/CD 60038", "IEC/FDIS 60038", "IEC/FDAM 60038-1",
              "IEC/DCOR 60038-1", "IEC/DISH 60050-191", "ISO/IEC PAS 62975",
              "IEC PNW 1000-1:2023 ED2"]

    inputs.each do |input|
      once = Pubid::Iec.parse(input).to_s
      expect(Pubid::Iec.parse(once).to_s).to eq(once)
    end
  end
end
