# frozen_string_literal: true

require "spec_helper"

# ISO holds `number`, `part` and `subpart` as plain :string attributes.
#
# `Iso::Components::Code` existed to join `parts` with "-", and that
# composition was unreachable: measured over the whole 7,613-id pass corpus,
# no ISO identifier populates `prefix`, `part`, `subpart` or `parts` INSIDE
# the Code, `parts` is never written anywhere in lib/pubid/iso, and no Code
# renders differently from its own `value`. ISO's part and subpart are sibling
# attributes, not fields of the number.
#
# The serialized shape does not move: ISO's key_value block already emitted a
# bare scalar (`"number" => "9001"`), so no relaton-data-iso row changes.
#
# `Pubid::Iso::Components::Code` is deleted, and so is every other ISO use of
# a Code on the identifier path: the committee structure (`tc_*`/`sc_*`/`wg_*`),
# the directives `subgroup`, and `edition.number`. The last one mattered beyond
# tidiness — `Components::Edition#number` is typed Value, so lutaml passed the
# live object into `to_hash` and `to_yaml` emitted `!ruby/object:`.
#
# Two wire formats move, both deliberately and without a compatibility shim:
# `subgroup` flattens from `{"value" => "JTC 1"}` to `"JTC 1"` (5 rows of the
# published relaton-data-iso index, which needs a re-crawl), and an edition
# serializes `{"number" => "13", "original_text" => "Ed 13"}` (no published row
# carries an edition today).
module IsoNumberStringSpec
  # reference => [printed, urn, number, part, subpart]
  REFS = {
    "ISO 9001:2015" => ["ISO 9001:2015", "urn:iso:std:iso:9001",
                        "9001", nil, nil],
    "ISO 1234-1:2020" => ["ISO 1234-1:2020", "urn:iso:std:iso:1234:-1",
                          "1234", "1", nil],
    "ISO 29110-5-1-1:2011" => ["ISO 29110-5-1-1:2011",
                               "urn:iso:std:iso:29110:-5-1-1",
                               "29110", "5", "1-1"],
  }.freeze
end

RSpec.describe "ISO number as a string" do
  describe "the attribute types" do
    %i[number part subpart].each do |attr|
      it "declares #{attr} as a plain string" do
        expect(Pubid::Iso::Identifier.attributes[attr].type)
          .to eq(Lutaml::Model::Type::String)
      end
    end

    it "no longer defines a flavor Code subclass" do
      expect(Pubid::Iso::Components.const_defined?(:Code, false)).to be(false)
    end

    it "holds the committee structure as plain strings too" do
      %i[tc_type tc_number sc_type sc_number wg_type wg_number].each do |attr|
        expect(Pubid::Iso::Identifiers::TcDocument.attributes[attr].type)
          .to eq(Lutaml::Model::Type::String)
      end
      expect(Pubid::Iso::Identifiers::Directives.attributes[:subgroup].type)
        .to eq(Lutaml::Model::Type::String)
    end
  end

  IsoNumberStringSpec::REFS.each do |ref, (printed, urn, number, part, subpart)|
    context "with #{ref}" do
      let(:id) { Pubid::Iso.parse(ref) }

      it "holds the number trio as Strings" do
        expect(id.number).to eq(number)
        expect(id.number).to be_a(String)
        expect(id.part).to eq(part)
        expect(id.subpart).to eq(subpart)
        expect(id.root.number).to be_a(String)
      end

      it "renders and serializes as before" do
        expect(id.to_s).to eq(printed)
        expect(id.to_urn).to eq(urn)
        expect(id.to_hash["number"]).to eq(number)
      end

      it "round-trips through from_hash" do
        hash = id.to_hash

        expect(Pubid::Iso::Identifier.from_hash(hash).to_hash).to eq(hash)
        expect(Pubid::Iso::Identifier.from_hash(hash)).to eq(id)
      end
    end
  end

  # A TC document holds its whole committee structure as strings.
  describe "a TC document" do
    it "renders and keeps its number a String" do
      id = Pubid::Iso.parse("ISO/TC 184/SC 4 N 1234")

      expect(id.to_s).to eq("ISO/TC 184/SC 4 N 1234")
      expect(id.to_urn).to eq("urn:iso:doc:iso:tc:184:sc-4:1234")
      expect(id.number).to be_a(String)
      expect(id.tc_number).to eq("184")
    end
  end
end
