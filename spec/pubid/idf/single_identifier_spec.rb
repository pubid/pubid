# frozen_string_literal: true

require "spec_helper"
require "lutaml/model"

RSpec.describe Pubid::Idf::SingleIdentifier do
  # Test that SingleIdentifier inherits from Identifier
  it "is a subclass of Pubid::Idf::Identifier" do
    expect(described_class).to be < Pubid::Idf::Identifier
  end

  # Test that SingleIdentifier has typed_stage attribute (inherited from base)
  it "has typed_stage attribute" do
    identifier = described_class.new

    expect(identifier).to respond_to(:typed_stage)
    expect(identifier).to respond_to(:typed_stage=)
  end

  # Test that SingleIdentifier has type attribute (inherited from base)
  it "has type attribute" do
    identifier = described_class.new

    expect(identifier).to respond_to(:type)
    expect(identifier).to respond_to(:type=)
  end

  # Test that SingleIdentifier can have typed_stage set
  it "can have typed_stage set" do
    typed_stage = Pubid::Components::TypedStage.new(
      code: :published,
      stage_code: :published,
      type_code: :is,
      abbr: [""],
      name: "International Standard",
    )

    identifier = described_class.new(typed_stage: typed_stage)

    expect(identifier.typed_stage).to eq(typed_stage)
  end

  # Test that a concrete SingleIdentifier subclass can be instantiated
  describe "with a concrete class" do
    let(:concrete_class) do
      Class.new(Pubid::Idf::SingleIdentifier) do
        attribute :type, Pubid::Components::Type, default: -> { self.class.type[:key] }

        def self.type
          { key: :test, title: "Test Type", short: "TST" }
        end
      end
    end

    it "can be instantiated" do
      identifier = concrete_class.new
      expect(identifier).to be_a(described_class)
    end

    it "has the type method" do
      expect(concrete_class.type).to eq({ key: :test, title: "Test Type",
                                          short: "TST" })
    end
  end
end
