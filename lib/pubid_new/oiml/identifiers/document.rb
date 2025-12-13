# frozen_string_literal: true

module PubidNew
  module Oiml
    module Identifiers
      class Document < SingleIdentifier
        def type_string
          "D"
        end
      end
    end
  end
end