# frozen_string_literal: true

require "spec_helper"

# The wrapper rules are in all_parts_identifier_spec.rb.
RSpec.describe "Pubid::Identifier#to_all_parts" do
  let(:id) { Pubid::Iso.parse("ISO 9000-1:2015") }
  let(:all) { id.to_all_parts }

  it "returns an all-parts identifier that holds the reference" do
    expect(all).to be_a(Pubid::AllParts)
    expect(all.identifiers).to eq([id])
  end

  it "does not change the receiver" do
    all
    expect(id.to_s).to eq("ISO 9000-1:2015")
    expect(id.all_parts).to be false
  end

  it "gives the same result for a reference with no part" do
    whole = Pubid::Iso.parse("ISO 9000").to_all_parts
    expect(whole.to_s).to eq("ISO 9000 (all parts)")
  end

  # One identifier per registered flavor.
  context "with every registered flavor" do
    Pubid.eager_load_flavors!
    Pubid::Registry.flavor_names.each do |flavor|
      it "#{flavor} returns an all-parts identifier" do
        klass = Pubid::Registry.get(flavor)::Identifier
        all = klass.new(number: "1", part: "2").to_all_parts
        expect(all).to be_a(Pubid::AllParts)
        expect(all.root).to be_an_instance_of(klass)
      end
    end
  end
end
