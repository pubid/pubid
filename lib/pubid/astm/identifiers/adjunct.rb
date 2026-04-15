# frozen_string_literal: true

module Pubid
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
          result << "ADJ#{designation}#{'-EA' if ea_suffix}#{'DVD' if dvd_suffix}"
          result.compact.join(" ")
        end
      end
    end
  end
end
