# frozen_string_literal: true

module Pubid
  module Astm
    module Identifiers
      class Adjunct < SingleIdentifier
        attribute :designation, :string      # D2148, F3504, G0088, C062702
        attribute :ea_suffix, :boolean       # -EA
        attribute :dvd_suffix, :boolean      # DVD
      end
    end
  end
end
