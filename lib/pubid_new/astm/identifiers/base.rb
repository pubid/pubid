# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class Base < SingleIdentifier
        def self.parse(str)
          PubidNew::Astm::Identifier.parse(str)
        end
      end
    end
  end
end
