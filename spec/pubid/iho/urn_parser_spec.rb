# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iho"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Iho::UrnParser do
  # parse -> to_urn -> parse must preserve every component, for plain
  # and nested (containment) shapes alike.
  it_behaves_like "flavor URN round-trip", Pubid::Iho, [
    "IHO S-44 5.0.0",
    "IHO S-100 5.0.0 Part 2",
    "IHO S-98 1.0.0 Part A Annex A",
    "IHO S-122 1.0.0 Appendix D-2",
    "IHO S-52 4.0.0 Appendix 1",
    "IHO S-66 2.0.0 Sup 4",
    "IHO M-2 Sup 1",
    "IHO P-5 Vol. 2024",
    "IHO P-1 Vol. 30",
    "IHO P-1 Vol. 30 (2)",
    "IHO P-1 1.0.0 Vol. 21",
    "IHO S-100 5.0.0 Part 2 (2024)",
    "IHO S-158:100",
    "IHO S-158:100 1.0.0",
    "IHO S-158:100 Part 2 1.0.0",
    "IHO S-158:2024",
    "IHO S-158 Vol. 2024",
    "IHO S-100",
  ]

  # The number occupies every leading bare segment (a colon number is
  # not escaped), every other component is a marker segment, and the
  # appendix subnumber is the only bare atom after a marker.
  {
    "urn:iho:s:158:100" => "IHO S-158:100",
    "urn:iho:s:158:100:ed-1.0.0" => "IHO S-158:100 1.0.0",
    "urn:iho:s:158:100:part-2:ed-1.0.0" => "IHO S-158:100 Part 2 1.0.0",
    "urn:iho:s:158:2024" => "IHO S-158:2024",
    "urn:iho:s:158:vol-2024" => "IHO S-158 Vol. 2024",
    "urn:iho:s:122:ed-1.0.0:appendix-D:2" => "IHO S-122 1.0.0 Appendix D-2",
    "urn:iho:p:5:vol-2024" => "IHO P-5 Vol. 2024",
    "urn:iho:p:1:vol-30:issue-2" => "IHO P-1 Vol. 30 (2)",
    "urn:iho:s:100:ed-5.0.0:part-2:year-2024" =>
      "IHO S-100 5.0.0 Part 2 (2024)",
    "urn:iho:m:2:sup-1" => "IHO M-2 Sup 1",
    # the positional ed- attach: a component edition lands on its
    # component, a bare base edition on the base
    "urn:iho:p:6:vol-2:ed-1.0.1" => "IHO P-6 Vol. 2 1.0.1",
    "urn:iho:p:6:ed-1.0.0:vol-2" => "IHO P-6 1.0.0 Vol. 2",
    "urn:iho:s:158:part-S-102:ed-0.2.0" => "IHO S-158 Part S-102 0.2.0",
    "urn:iho:s:98:part-A:ed-1.0.0:year-2024" => "IHO S-98 Part A 1.0.0 (2024)",
    "urn:iho:s:122:appendix-D:2:ed-1.0.0" => "IHO S-122 Appendix D-2 1.0.0",
  }.each do |urn, text|
    it "decodes #{urn.inspect} as #{text.inspect}" do
      expect(described_class.new.parse_urn(urn).to_s).to eq(text)
    end
  end

  # --- legacy 2.0.x spellings: decodable, never emitted ---
  {
    # the #635/#637 y. year tag: the yearbook year IS a volume, so the
    # value decodes into the volume component (urn:iho:p:5:y.2024 now
    # re-emits as urn:iho:p:5:vol-2024)
    "urn:iho:p:5:y.2024" => "IHO P-5 Vol. 2024",
    "urn:iho:s:158:y.2024" => "IHO S-158 Vol. 2024",
    "urn:iho:p:1:vol.30:issue.2" => "IHO P-1 Vol. 30 (2)",
    "urn:iho:s:66:suppl.1:2.0.0" => "IHO S-66 2.0.0 Sup 1",
    "urn:iho:s:65:ap.A:1.0.0" => "IHO S-65 1.0.0 Appendix A",
    "urn:iho:s:100:part.4a:1.0.0" => "IHO S-100 1.0.0 Part 4a",
    "urn:iho:s:100:annex.A:5.2.0" => "IHO S-100 5.2.0 Annex A",
    "urn:iho:b:1:1.0.0" => "IHO B-1 1.0.0", # the bare a.b.c edition
    # the legacy appendix stored the subnumber inside one string
    "urn:iho:s:122:ed-1.0.0:appendix.D-2" => "IHO S-122 1.0.0 Appendix D-2",
  }.each do |urn, text|
    it "decodes legacy #{urn.inspect} as #{text.inspect}" do
      id = described_class.new.parse_urn(urn)
      expect(id.to_s).to eq(text)
    end
  end

  # --- strict positional validation: unknown, malformed or duplicate
  #     segments are rejected, never mis-consumed ---
  {
    "urn:iho:x:100" => "unknown IHO series",
    "urn:iho:s" => "missing docnumber",
    "urn:iho:s:100:junk-segment" => "unexpected segment",
    "urn:iho:s:100:part-A1" => "invalid part value",
    "urn:iho:s:100:annex-BC" => "invalid annex value",
    "urn:iho:s:100:ed-1.0" => "invalid edition value",
    "urn:iho:s:100:year-19" => "invalid year value",
    "urn:iho:s:100:ed-1.0.0:ed-2.0.0" => "duplicate edition segment",
    "urn:iho:s:100:vol-30:vol-31" => "duplicate volume segment",
    "urn:iho:s:100:appendix-D:2:3" => "stray bare atom after the subnumber",
  }.each do |urn, reason|
    it "rejects #{urn.inspect} (#{reason})" do
      expect { described_class.new.parse_urn(urn) }
        .to raise_error(Pubid::Errors::UrnParseError)
    end
  end

  # The owner-demanded nested round trips: the containment tree survives
  # parse -> URN -> parse AND parse -> hash -> parse.
  {
    "IHO S-98 1.0.0 Annex A" => %i[edition annex],
    "IHO P-6 Vol. 2 1.0.1" => %i[volume volume_edition],
    "IHO S-158 Part S-102 0.2.0" => %i[part part_edition],
    "IHO S-122 1.0.0 Appendix D-2" => %i[edition appendix appendix_subnumber],
    "IHO S-100 5.0.0 Part 2 (2024)" => %i[edition part year],
  }.each do |text, components|
    it "round-trips #{text.inspect} through the URN and the hash" do
      id = Pubid::Iho.parse(text)
      from_urn = Pubid::Iho::UrnParser.parse(id.to_urn)
      expect(from_urn.to_s).to eq(id.to_s)
      expect(from_urn.to_urn).to eq(id.to_urn)
      components.each do |component|
        expect(from_urn.public_send(component)).to eq(id.public_send(component))
      end

      from_hash = Pubid::Iho::Identifier.from_hash(id.to_hash)
      expect(from_hash).to eq(id)
      expect(from_hash.to_urn).to eq(id.to_urn)
    end
  end
end
