# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Resolutions and other Council publications (P prefix,
      # planned). Today resolutions carry no code; P is reserved for
      # future numbered resolutions.
      class Resolution < Identifier
        def self.type
          { key: :resolution, title: "Resolution", short: "P" }
        end
      end
    end
  end
end
