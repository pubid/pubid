# frozen_string_literal: true

require "spec_helper"
require "json"

# The grammar's doc_type alternatives (data/parg/sae.json) and the Ruby type
# table (Pubid::Sae::Components::Type::TYPES) describe one list. The grammar
# must read every family the builder can store, in both spellings, longest
# first, and nothing the builder cannot canonicalize.
RSpec.describe Pubid::Sae::Components::Type do
  let(:source) do
    path = File.expand_path("../../../data/parg/sae.json", __dir__)
    JSON.parse(File.read(path)).fetch("source")
  end

  let(:alternatives) do
    rule = source[/^\s*doc_type = \((.*)\) as type$/, 1]
    rule.scan(/"([^"]+)"/).flatten
  end

  let(:expected) do
    keys = described_class::TYPES.keys
    (keys + keys.map { |k| k.delete("-") }).uniq
  end

  it "lists every family in both spellings, and nothing else" do
    expect(alternatives).to match_array(expected)
  end

  it "orders the alternatives so no earlier one is a prefix of a later one" do
    alternatives.each_with_index do |alt, i|
      later = alternatives[(i + 1)..].select { |b| b.start_with?(alt) }
      expect(later).to be_empty, "#{alt} shadows #{later.join(', ')}"
    end
  end

  it "canonicalizes each spelling to its printed form" do
    expect(described_class.canonical("AMSQQA")).to eq("AMS-QQ-A")
    expect(described_class.canonical("ams-qq-a")).to eq("AMS-QQ-A")
    expect(described_class.canonical("J")).to eq("J")
    expect(described_class.canonical("XYZ")).to be_nil
  end
end
