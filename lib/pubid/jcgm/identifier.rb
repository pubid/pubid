# frozen_string_literal: true

module Pubid
  module Jcgm
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        Pubid::Jcgm.parse(string)
      end
    end
  end
end
