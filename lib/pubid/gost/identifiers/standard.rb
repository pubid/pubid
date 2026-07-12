# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # A GOST standard — interstate ("GOST") or Russian national
      # ("GOST R"). A single class handles both because the only
      # structural difference is the optional "R" marker, captured in
      # the inherited `scope` attribute.
      #
      # Examples:
      #   GOST 14946-82          (interstate, 2-digit year)
      #   GOST R 34.12-2015      (Russian national, dotted number, 4-digit year)
      class Standard < Base
        def self.type
          { key: :standard, title: "Standard", short: "GOST" }
        end
      end
    end
  end
end
