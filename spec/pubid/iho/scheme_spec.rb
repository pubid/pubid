# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iho::Scheme do
  it "inherits from Pubid::Scheme" do
    expect(described_class).to be < Pubid::Scheme
  end

  describe "#identifiers" do
    let(:scheme) { described_class.new }

    it "exposes the five IHO series classes" do
      expect(scheme.identifiers).to contain_exactly(
        Pubid::Iho::Identifiers::Standard,
        Pubid::Iho::Identifiers::Publication,
        Pubid::Iho::Identifiers::Miscellaneous,
        Pubid::Iho::Identifiers::Bibliographic,
        Pubid::Iho::Identifiers::CircularLetter,
      )
    end

    it "is frozen" do
      expect(scheme.identifiers).to be_frozen
    end
  end

  describe ".identifier_klass_for_type_letter" do
    {
      "S" => Pubid::Iho::Identifiers::Standard,
      "P" => Pubid::Iho::Identifiers::Publication,
      "M" => Pubid::Iho::Identifiers::Miscellaneous,
      "B" => Pubid::Iho::Identifiers::Bibliographic,
      "C" => Pubid::Iho::Identifiers::CircularLetter,
    }.each do |letter, klass|
      it "maps #{letter.inspect} to #{klass.name.split('::').last}" do
        expect(described_class.identifier_klass_for_type_letter(letter)).to eq(klass)
      end
    end

    it "raises for an unknown letter" do
      expect { described_class.identifier_klass_for_type_letter("X") }.to raise_error(KeyError)
    end
  end

  it "is registered with Pubid::Registry" do
    expect(Pubid::Registry.get(:iho)).to eq(Pubid::Iho)
  end
end
