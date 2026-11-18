# frozen_string_literal: true

module Pubid
  module Eu
    module Identifiers
      # An EU regulation (CELEX sector 3, letter R; ELI segment "reg").
      class Regulation < Identifier
        def self.type
          { key: :regulation, title: "Regulation", celex: "R", eli: "reg" }
        end
      end
    end
  end
end
