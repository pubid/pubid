# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Standards (S series).
      # Examples: S1010, S1020 Ed 2.0, S1070 Ed 2.0.
      class Standard < Base
        def self.type
          { key: :standard, title: "Standard", short: "S" }
        end
      end
    end
  end
end
