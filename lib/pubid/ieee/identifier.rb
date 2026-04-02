# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifier
      class << self
        def parse(input)
          Identifiers::Base.parse(input)
        end
      end
    end
  end
end
