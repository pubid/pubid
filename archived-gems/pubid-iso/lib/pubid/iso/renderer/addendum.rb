require_relative "supplement"

module Pubid
  module Iso
    module Renderer
      class Addendum < Supplement
        TYPE = "Add".freeze
      end
    end
  end
end
