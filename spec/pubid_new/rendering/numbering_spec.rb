# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/rendering/numbering"
require_relative "../../../lib/pubid_new/components/code"

RSpec.describe PubidNew::Rendering::Numbering do
  let(:test_class) do
    Class.new do
      include PubidNew::Rendering::Numbering

      attr_accessor :number, :part, :subpart
    end
  end

  let(:instance) { test_class.new }

  describe "#render_numbering" do
    it "renders number only" do
      number = PubidNew::Components::Code.new(value: "9001")
      expect(instance.render_numbering(number)).to eq(" 9001")
    end

    it "renders number with part" do
      number = PubidNew::Components::Code.new(value: "9001")
      part = PubidNew::Components::Code.new(value: "1")
      expect(instance.render_numbering(number, part)).to eq(" 9001-1")
    end

    it "renders number with part and subpart" do
      number = PubidNew::Components::Code.new(value: "9001")
      part = PubidNew::Components::Code.new(value: "1")
      subpart = PubidNew::Components::Code.new(value: "A")
      expect(instance.render_numbering(number, part, subpart)).to eq(" 9001-1-A")
    end

    it "uses custom part separator" do
      number = PubidNew::Components::Code.new(value: "9001")
      part = PubidNew::Components::Code.new(value: "1")
      expect(instance.render_numbering(number, part, nil, part_separator: ".")).to eq(" 9001.1")
    end

    it "returns empty string for nil number" do
      expect(instance.render_numbering(nil)).to eq("")
    end
  end
end
