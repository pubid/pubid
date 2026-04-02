# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class Adjunct < SingleIdentifier
        attribute :designation, :string      # D2148, F3504, G0088, C062702
        attribute :ea_suffix, :boolean       # -EA
        attribute :dvd_suffix, :boolean      # DVD

        def to_s
          result = []
          # Only include publisher for simple adjuncts (no EA or DVD suffix)
          result << publisher if publisher && !ea_suffix && !dvd_suffix
          result << "ADJ#{designation}#{ea_suffix ? '-EA' : ''}#{dvd_suffix ? 'DVD' : ''}"
          result.compact.join(" ")
        end
      end
    end
  end
end
