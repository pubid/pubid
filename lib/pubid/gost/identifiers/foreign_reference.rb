# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # Foreign reference captured verbatim when no registered flavor can
      # parse the adopted identifier (e.g. "OECD 460:2017",
      # "UNECE STANDARD FFV-18:2011"). It preserves the raw surface form
      # for round-trip rendering without modelling the foreign standard's
      # internal structure. Quacks like Pubid::Identifier for rendering
      # and serialization.
      class ForeignReference < Base
        attribute :raw, :string

        def self.type
          { key: :"foreign-reference", title: "Foreign Reference", short: nil }
        end

        def to_s
          raw.to_s
        end
      end
    end
  end
end
