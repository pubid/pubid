# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/rendering/date"
require_relative "../../../lib/pubid/components/date"

RSpec.describe Pubid::Rendering::Date do
  let(:test_class) do
    Class.new do
      include Pubid::Rendering::Date

      attr_accessor :date
    end
  end

  let(:instance) { test_class.new }

  describe "#render_date" do
    it "renders year only" do
      date = Pubid::Components::Date.new(year: 2015)
      expect(instance.render_date(date)).to eq(":2015")
    end

    it "renders year with month" do
      date = Pubid::Components::Date.new(year: 2015, month: 6)
      expect(instance.render_date(date, include_month: true)).to eq(":2015-06")
    end

    it "renders year with month and day" do
      date = Pubid::Components::Date.new(year: 2015, month: 6, day: 15)
      expect(instance.render_date(date, include_month: true,
                                        include_day: true)).to eq(":2015-06-15")
    end

    it "does not include month when option not set" do
      date = Pubid::Components::Date.new(year: 2015, month: 6)
      expect(instance.render_date(date)).to eq(":2015")
    end

    it "returns empty string for nil date" do
      expect(instance.render_date(nil)).to eq("")
    end
  end
end
