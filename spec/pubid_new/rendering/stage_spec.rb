# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/rendering/stage"
require_relative "../../../lib/pubid/components/stage"
require_relative "../../../lib/pubid/components/type"

RSpec.describe Pubid::Rendering::Stage do
  let(:test_class) do
    Class.new do
      include Pubid::Rendering::Stage

      attr_accessor :stage, :type
    end
  end

  let(:instance) { test_class.new }

  describe "#render_stage" do
    it "renders stage only" do
      stage = Pubid::Components::Stage.new(abbr: "WD")
      expect(instance.render_stage(stage)).to eq("/WD")
    end

    it "renders stage with copublisher" do
      stage = Pubid::Components::Stage.new(abbr: "WD")
      expect(instance.render_stage(stage, nil, has_copublisher: true)).to eq(" WD")
    end

    it "renders stage and type" do
      stage = Pubid::Components::Stage.new(abbr: "WD")
      type = Pubid::Components::Type.new(abbr: "TR")
      expect(instance.render_stage(stage, type)).to eq("/WD/TR")
    end

    it "renders stage and type with copublisher" do
      stage = Pubid::Components::Stage.new(abbr: "WD")
      type = Pubid::Components::Type.new(abbr: "TR")
      expect(instance.render_stage(stage, type, has_copublisher: true)).to eq(" WD TR")
    end

    it "does not render default type" do
      stage = Pubid::Components::Stage.new(abbr: "DIS")
      type = Pubid::Components::Type.new(abbr: "IS")
      expect(instance.render_stage(stage, type)).to eq("/DIS")
    end

    it "returns empty string for nil stage" do
      expect(instance.render_stage(nil)).to eq("")
    end
  end
end
