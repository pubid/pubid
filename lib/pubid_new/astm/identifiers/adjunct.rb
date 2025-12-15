# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class Adjunct < Base
        attribute :designation, :string      # D2148, F3504, G0088, C062702
        attribute :ea_suffix, :boolean       # -EA
        attribute :dvd_suffix, :boolean      # DVD

        def to_s
          parts = []
          parts << publisher if publisher

          result = parts.join(" ")
          result += " " if publisher && !result.end_with?(" ")

          result += "ADJ"
          result += designation if designation
          result += "-EA" if ea_suffix
          result += "DVD" if dvd_suffix
          result
        end
      end
    end
  end
end