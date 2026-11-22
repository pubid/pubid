# frozen_string_literal: true

require "spec_helper"

# Every pass fixture row round-trips through the MRN URN: the generator's
# form re-parses to the same identifier and the same face.
RSpec.describe Pubid::Wmo::UrnGenerator do
  it "rebuilds every identifier its generator emits" do
    Dir[File.expand_path("../../fixtures/wmo/identifiers/pass/*.txt", __dir__)]
      .flat_map { |f| File.readlines(f).map(&:strip) }
      .reject { |line| line.empty? || line.start_with?("#") }
      .map { |line| line.sub(/\A!([^!]*)!.*/, '\1') }
      .uniq
      .each do |input|
        id = Pubid::Wmo.parse(input)
        next unless id.respond_to?(:to_urn)

        round = Pubid::Wmo.parse(id.to_urn)
        expect(round).to eq(id),
                         "#{input}: #{id.to_urn} rebuilt #{round.to_s.inspect}"
        expect(round.to_s).to eq(id.to_s),
                              "#{input}: #{id.to_urn} re-rendered differently"
      end
  end
end
