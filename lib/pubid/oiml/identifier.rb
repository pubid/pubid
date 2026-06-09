# frozen_string_literal: true

module Pubid
  module Oiml
    class Identifier < Pubid::Identifier
      def to_urn
        UrnGenerator.new(self).generate
      end
    end
  end
end
