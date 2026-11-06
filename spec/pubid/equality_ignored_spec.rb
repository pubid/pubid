# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::EqualityIgnored do
  let(:component) do
    Class.new(Lutaml::Model::Serializable) do
      include Pubid::SubsetMatch
      include Pubid::EqualityIgnored

      attribute :code, :string
      attribute :spelling, :string
      equality_ignored :spelling
    end
  end

  let(:plain) do
    Class.new(Lutaml::Model::Serializable) do
      include Pubid::SubsetMatch
      include Pubid::EqualityIgnored

      attribute :code, :string
      attribute :spelling, :string
    end
  end

  describe "a class that declares an ignored attribute" do
    let(:first) { component.new(code: "en", spelling: "E") }
    let(:second) { component.new(code: "en", spelling: "en") }

    it "is == when only the ignored attribute differs" do
      expect(first).to eq(second)
      expect(first).to eql(second)
    end

    it "has the same hash when only the ignored attribute differs" do
      expect(first.hash).to eq(second.hash)
    end

    it "is one Hash key and one uniq entry" do
      expect([first, second].uniq.size).to eq(1)
      expect({ first => 1 }).to have_key(second)
    end

    it "matches with === in both directions" do
      expect(first === second).to be(true)
      expect(second === first).to be(true)
      expect(component.new(code: "en") === first).to be(true)
    end

    it "still compares the other attributes" do
      other = component.new(code: "fr", spelling: "E")
      expect(first).not_to eq(other)
      expect(first === other).to be(false)
    end
  end

  describe "a class that declares nothing" do
    it "keeps lutaml's ==, comparing every attribute" do
      expect(plain.new(code: "en", spelling: "E"))
        .not_to eq(plain.new(code: "en", spelling: "en"))
    end
  end

  describe "inheritance" do
    it "passes the declaration to a subclass, which can add its own" do
      klass = Class.new(component) do
        attribute :joiner, :string
        equality_ignored :joiner
      end
      expect(klass.equality_ignored_attributes)
        .to contain_exactly(:spelling, :joiner)
      expect(component.equality_ignored_attributes).to eq([:spelling])
    end
  end
end
