# frozen_string_literal: true

module Pubid
  module Eu
    module Identifiers
      # An EU decision (CELEX sector 3, letter D; ELI segment "dec").
      class Decision < Identifier
        def self.type
          { key: :decision, title: "Decision", celex: "D", eli: "dec" }
        end
      end
    end
  end
end
