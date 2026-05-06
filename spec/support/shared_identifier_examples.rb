# frozen_string_literal: true

RSpec.shared_examples "URN round-trip" do |identifier_string|
  it "round-trips '#{identifier_string}' through URN" do
    id = described_class.parse(identifier_string)
    urn = id.to_urn
    expect(urn).to start_with("urn:")
    id2 = described_class.parse(urn)
    expect(id2.to_urn).to eq(urn)
  end
end

RSpec.shared_examples "serialization" do |identifier_string|
  it "serializes '#{identifier_string}' to hash" do
    id = described_class.parse(identifier_string)
    h = id.to_h
    expect(h).to be_a(Hash)
    expect(h).not_to be_empty
  end

  it "serializes '#{identifier_string}' to JSON" do
    id = described_class.parse(identifier_string)
    json = id.to_json
    parsed = JSON.parse(json)
    expect(parsed).to be_a(Hash)
    expect(parsed).not_to be_empty
  end
end

RSpec.shared_examples "parse rejection" do
  it "rejects empty input" do
    expect { described_class.parse("") }.to raise_error(StandardError)
  end

  it "rejects nil input" do
    expect { described_class.parse(nil) }.to raise_error(StandardError)
  end
end

RSpec.shared_examples "parse and render" do |identifier_string|
  it "parses and renders '#{identifier_string}'" do
    id = described_class.parse(identifier_string)
    rendered = id.to_s
    expect(rendered).not_to be_empty
    expect(rendered).to be_a(String)
  end
end
