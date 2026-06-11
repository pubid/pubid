# frozen_string_literal: true

module Pubid
  module Api
    module Identifiers
      class Publication < Base
        def type_string
          "PUBL"
        end
      end
    end
  end
end
