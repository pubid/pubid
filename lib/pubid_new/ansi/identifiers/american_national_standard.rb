require_relative "../single_identifier"

module PubidNew
  module Ansi
    module Identifiers
      # American National Standard identifier
      class AmericanNationalStandard < SingleIdentifier
        def self.type
          { key: :ans, title: "American National Standard", short: "ANS" }
        end
      end
    end
  end
end