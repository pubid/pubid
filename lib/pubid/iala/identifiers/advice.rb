# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Advices (A prefix). Numbering is dashed: A12-01, A13-04.
      # Carries no edition in the corpus.
      class Advice < Identifier
        def self.type
          { key: :advice, title: "Advice", short: "A" }
        end
      end
    end
  end
end
