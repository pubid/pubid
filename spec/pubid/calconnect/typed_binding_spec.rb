# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CalConnect typed model bindings" do
  include FixtureFileHelper

  def fixture_path(name)
    File.expand_path("../../fixtures/calconnect/identifiers/#{name}", __dir__)
  end

  def tree_path(input)
    Pubid::Calconnect::Builder.build(
      Pubid::Parg::Backend.parse(:calconnect, input),
    )
  end

  it "materializes the same identifier as the tree + builder path" do
    entries = read_pass_fixture_entries(fixture_path("pass/standard.txt"))
    expect(entries).not_to be_empty

    differences = entries.filter_map do |input, expected|
      typed = Pubid::Calconnect.parse(input)
      tree = tree_path(input)

      next if typed.to_hash == tree.to_hash && typed.to_s == expected

      { input: input, expected: expected, typed: typed.to_hash,
        tree: tree.to_hash }
    end

    expect(differences).to eq([])
  end

  it "rejects every fail fixture with a ParseError" do
    inputs = read_fixture_file(fixture_path("fail/standard.txt"))
    expect(inputs).not_to be_empty

    inputs.each do |input|
      expect { Pubid::Calconnect.parse(input) }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  it "keeps the all-parts suffix off the grammar and on the model" do
    input = "CC/A 0812-1:2008 (all parts)"
    typed = Pubid::Calconnect.parse(input)
    tree = tree_path(input)

    expect(typed).to be_a(Pubid::AllPartsIdentifier)
    expect(typed).to eq(tree)
    expect(typed.to_s).to eq(tree.to_s)
  end
end
