# frozen_string_literal: true

module Pubid
  module Renderers
    class Base
      def initialize(identifier)
        @id = identifier
      end

      def render
        raise NotImplementedError, "#{self.class}#render not implemented"
      end

      def self.render(identifier)
        new(identifier).render
      end
    end
  end
end
