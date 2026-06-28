# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Electronic Publication (EP) identifier
      class ElectronicBook < SingleIdentifier
        def self.type
          { key: :ep,
            web: :electronic_book, title: "Electronic Publication", short: "EP" }
        end

      end
    end
  end
end
