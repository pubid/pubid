# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/rendering/format"

RSpec.describe PubidNew::Rendering::Format do
  let(:test_class) do
    Class.new do
      include PubidNew::Rendering::Format

      def to_short_style
        "short"
      end

      def to_full_style
        "full"
      end

      def to_mr_style
        "mr"
      end
    end
  end

  let(:instance) { test_class.new }

  describe "#to_s" do
    it "dispatches to short style by default" do
      expect(instance.to_s).to eq("short")
    end

    it "dispatches to short style explicitly" do
      expect(instance.to_s(:short)).to eq("short")
    end

    it "dispatches to full style" do
      expect(instance.to_s(:full)).to eq("full")
    end

    it "dispatches to long style (same as full)" do
      expect(instance.to_s(:long)).to eq("full")
    end

    it "dispatches to mr style" do
      expect(instance.to_s(:mr)).to eq("mr")
    end
  end
end
