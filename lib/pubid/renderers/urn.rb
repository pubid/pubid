# frozen_string_literal: true

module Pubid
  module Renderers
    class Urn < Base
      def render(context: nil, **)
        @id.to_urn
      end
    end
  end
end
