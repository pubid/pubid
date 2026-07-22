# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Manuals (M prefix, planned).
      # Today manuals carry no code (NAVGUIDE, VTS Manual, …); M is
      # reserved for future numbered manuals.
      class Manual < Identifier
        number_width 4

        def self.type
          { key: :manual, title: "Manual", short: "M" }
        end
      end
    end
  end
end
