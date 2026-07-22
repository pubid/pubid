# frozen_string_literal: true

require "spec_helper"

# Guards Phase 2 of the hierarchy unification: the shared, dynamically-built
# `polymorphic_type_map` (lib/pubid/identifier.rb) must resolve every `_type`
# the hand-rolled static `*_TYPE_MAP`s resolve, to the SAME concrete class —
# otherwise deleting a static map would silently drop a deserialization route.
# When this is green for a flavor, that flavor's bespoke from_hash + static map
# can be removed.
RSpec.describe "polymorphic_type_map parity with static *_TYPE_MAP" do
  STATIC_MAPS = {
    "Pubid::Iso::Identifier"          => "ISO_TYPE_MAP",
    "Pubid::Jis::Identifier"          => "JIS_TYPE_MAP",
    "Pubid::Iec::Identifier"          => "IEC_TYPE_MAP",
    "Pubid::Ccsds::Identifier"        => "CCSDS_TYPE_MAP",
    "Pubid::Iho::Identifier"          => "IHO_TYPE_MAP",
  }.freeze

  STATIC_MAPS.each do |base_const, map_const|
    describe base_const do
      let(:base)   { Object.const_get(base_const) }
      let(:static) { base.const_get(map_const) }
      let(:dynamic) { base.polymorphic_type_map }

      it "covers every static `_type` key" do
        missing = static.keys - dynamic.keys
        expect(missing).to be_empty,
                           "dynamic map missing keys: #{missing.join(', ')}"
      end

      it "resolves each static key to the same concrete class" do
        mismatches = static.filter_map do |type, klass_name|
          dyn = dynamic[type]
          next if dyn && dyn.name == klass_name

          "#{type}: static=#{klass_name} dynamic=#{dyn&.name.inspect}"
        end
        expect(mismatches).to be_empty,
                              "class mismatches:\n#{mismatches.join("\n")}"
      end
    end
  end
end
