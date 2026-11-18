# frozen_string_literal: true

module Pubid
  module Eu
    module Identifiers
      # An EU directive (CELEX sector 3, letter L; ELI segment "dir").
      class Directive < Identifier
        def self.type
          { key: :directive, title: "Directive", celex: "L", eli: "dir" }
        end
      end
    end
  end
end
