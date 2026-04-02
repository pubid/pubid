# frozen_string_literal: true

module Pubid
  module Astm
    module Identifiers
      class Base < SingleIdentifier
        def self.parse(str)
          Pubid::Astm::Identifier.parse(str)
        end
      end
    end
  end
end
