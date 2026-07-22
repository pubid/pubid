# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Letters (L prefix). Numbering is dotted with a series, sub-series,
      # and item: L2.1.11, L2.7.1-2 (the trailing -2 is a sub-part on top of
      # the dotted number).
      class Letter < Identifier
        def self.type
          { key: :letter, title: "Letter", short: "L" }
        end
      end
    end
  end
end
