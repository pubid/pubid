# frozen_string_literal: true

module Pubid
  module Parsers
    class Base
      def self.parse(string)
        raise NotImplementedError, "#{self.class}.parse not implemented"
      end
    end
  end
end
