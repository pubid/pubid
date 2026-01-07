# frozen_string_literal: true

require_relative "base"
require_relative "../components/code"
require_relative "../components/date"

module PubidNew
  module Bsi
    module Identifiers
      # BSI Handbook
      # Examples: "Handbook 17:1963", "Handbook 3:1985"
      class Handbook < Base
        attribute :number, Bsi::Components::Code
        attribute :date, Bsi::Components::Date

        def self.type
          {
            short: "Handbook",
            full: "BSI Handbook"
          }
        end

        def to_s(lang: :en, lang_single: false)
          result = "Handbook #{number}"
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end