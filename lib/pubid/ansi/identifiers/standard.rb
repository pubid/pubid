# frozen_string_literal: true

module Pubid
  module Ansi
    module Identifiers
      # American National Standard identifier
      class Standard < SingleIdentifier
        def self.type
          { key: :ans, title: "American National Standard", short: "ANS" }
        end
      end
    end
  end
end
