# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA General Assembly resolutions (GA prefix). Numbering is dotted
      # with a series and an index: GA01.01, GA01.13. No edition.
      class GeneralAssembly < Identifier
        number_width 2
        dotted_segment_width 2

        def self.type
          { key: :"general-assembly", title: "General Assembly Resolution",
            short: "GA" }
        end
      end
    end
  end
end
