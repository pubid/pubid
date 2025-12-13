# frozen_string_literal: true

module PubidNew
  module Oiml
    module Identifiers
      class Amendment < SupplementIdentifier
        def supplement_type
          "Amendment"
        end
      end
    end
  end
end