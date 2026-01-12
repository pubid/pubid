# frozen_string_literal: true

require_relative "base"
require_relative "../components/code"
require_relative "../components/date"

module PubidNew
  module Bsi
    module Identifiers
      # British Industrial Practice (BIP)
      # Examples: "BIP 2225:2022", "BIP 0142:2014", "BIP 0009:2020"
      class BritishIndustrialPractice < Base
        attribute :number, Bsi::Components::Code
        attribute :date, Bsi::Components::Date

        def self.type
          {
            short: "BIP",
            full: "British Industrial Practice",
          }
        end

        def to_s(lang: :en, lang_single: false)
          result = "BIP #{number}"
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
