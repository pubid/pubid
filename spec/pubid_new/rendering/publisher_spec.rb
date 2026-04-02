# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/rendering/publisher"
require_relative "../../../lib/pubid/components/publisher"

RSpec.describe Pubid::Rendering::Publisher do
  let(:test_class) do
    Class.new do
      include Pubid::Rendering::Publisher

      attr_accessor :publisher, :copublisher
    end
  end

  let(:instance) { test_class.new }

  describe "#render_publisher" do
    it "renders single publisher" do
      publisher = Pubid::Components::Publisher.new(body: "ISO")
      expect(instance.render_publisher(publisher)).to eq("ISO")
    end

    it "renders publisher with one copublisher" do
      publisher = Pubid::Components::Publisher.new(body: "ISO")
      copublishers = [Pubid::Components::Publisher.new(body: "IEC")]
      expect(instance.render_publisher(publisher, copublishers)).to eq("ISO/IEC")
    end

    it "renders publisher with multiple copublishers" do
      publisher = Pubid::Components::Publisher.new(body: "ISO")
      copublishers = [
        Pubid::Components::Publisher.new(body: "IEC"),
        Pubid::Components::Publisher.new(body: "IEEE")
      ]
      expect(instance.render_publisher(publisher, copublishers)).to eq("ISO/IEC/IEEE")
    end

    it "uses custom separator" do
      publisher = Pubid::Components::Publisher.new(body: "ISO")
      copublishers = [Pubid::Components::Publisher.new(body: "IEC")]
      expect(instance.render_publisher(publisher, copublishers, copublisher_separator: ";")).to eq("ISO;IEC")
    end

    it "returns empty string for nil publisher" do
      expect(instance.render_publisher(nil)).to eq("")
    end
  end
end
