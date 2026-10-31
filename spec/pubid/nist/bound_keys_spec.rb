# frozen_string_literal: true

require "spec_helper"

# The typed-bindings contract for the NIST caster: the caster dispatches
# on wrapper-capture keys (first_number, edition_*, revision, update,
# stage, ...), so every key the parg tree ever surfaced for the caster
# must survive Pubid::Parg::Model.bound. A grammar edit that drops one of
# these keys fails the caster silently — identifiers lose their numbers —
# which the corpus's value probes cannot see.
RSpec.describe "NIST bound-hash caster keys" do
  sample = {
    "NIST SP 800-53" => %i[publisher series first_number second_number],
    "NIST.FIPS.197-upd1" => %i[publisher series update update_number update_prefix],
    "NBS.CIRC.sup" => %i[circ_series],
    "NBS BH 3nA" => %i[series first_number n_letter_part],
    "NBS CIRC 25e" => %i[series first_number],
    "NBS CIRC 11e2-1915" => %i[series first_number edition_dash_year],
    "NIST SP 801-errata" => %i[publisher series first_number revision],
    "NIST CSWP 27 ipd" => %i[publisher series stage stage_id stage_type],
    "NBS FIPS 100-1-1991" => %i[series second_number_edition_year],
    "NBS LC 118supp3/1926" => %i[series supplement_slash_year],
    "NBS HR 1-1nA" => %i[series n_letter_part],
    "NBS CIRC 488sec1" => %i[section],
    "NIST Research Library (2022)" => %i[publisher series year],
    "NBS SP 250e1982app" => %i[appendix],
    "NIST SP 800-38a-add" => %i[addendum],
    "NBS CIRC 25insert" => %i[insert],
    "NBS CIRC 74errata" => %i[errata],
    "NBS CIRC 15-April1909" => %i[series edition_month edition_year],
  }.freeze

  it "binds every caster-dispatched key the old tree surfaced" do
    sample.each do |input, keys|
      cleaned = Pubid::Nist::Preprocessor.new(input).call.cleaned
      bound = Pubid::Nist::Parser.normalize_bound(
        Pubid::Parg::Model.bound(:nist, cleaned),
      )
      missing = keys - bound.keys
      expect(missing).to be_empty,
        "#{input.inspect} lost caster keys #{missing.inspect}; bound: #{bound.keys.inspect}"
    end
  end

  it "parses every sampled input" do
    sample.each_key do |input|
      expect { Pubid::Nist.parse(input) }.not_to raise_error
    end
  end
end
