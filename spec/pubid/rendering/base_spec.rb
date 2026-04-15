# frozen_string_literal: true

require_relative "../../../lib/pubid/rendering/base"

RSpec.describe Pubid::Rendering::Base do
  class TestIdentifier
    include Pubid::Rendering::Base

    attr_accessor :publisher, :copublishers, :number, :part, :subpart, :date,
                  :stage, :type, :languages

    def initialize(publisher: nil, copublishers: nil, number: nil, part: nil,
subpart: nil, date: nil, stage: nil, type: nil, languages: nil)
      @publisher = publisher
      @copublishers = copublishers
      @number = number
      @part = part
      @subpart = subpart
      @date = date
      @stage = stage
      @type = type
      @languages = languages
    end

    def respond_to?(method)
      # Mock respond_to for all attributes
      %i[publisher copublishers number part subpart date stage
         type languages].include?(method)
    end
  end

  describe "#render_base" do
    it "renders publisher" do
      id = TestIdentifier.new(publisher: "ISO")
      expect(id.render_base).to eq("ISO")
    end

    it "renders publisher with copublisher" do
      id = TestIdentifier.new(publisher: "ISO", copublishers: ["IEC"])
      expect(id.render_base).to eq("ISO/IEC")
    end

    it "renders number with part" do
      id = TestIdentifier.new(
        number: Pubid::Components::Code.new(value: "9001"), part: Pubid::Components::Code.new(value: "1"),
      )
      expect(id.render_base).to eq(" 9001-1")
    end

    it "renders date" do
      id = TestIdentifier.new(
        number: Pubid::Components::Code.new(value: "9001"), date: Pubid::Components::Date.new(year: "2015"),
      )
      expect(id.render_base).to eq(" 9001:2015")
    end
  end
end
