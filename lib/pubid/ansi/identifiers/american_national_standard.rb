module Pubid
  module Ansi
    module Identifiers
      # American National Standard identifier
      class AmericanNationalStandard < SingleIdentifier
        def self.type
          { key: :ans, web: :american_national_standard,
            title: "American National Standard", short: "ANS" }
        end
      end
    end
  end
end
