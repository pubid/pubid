# frozen_string_literal: true

module Pubid
  module Parser
    module CommonParseMethods
      def array_to_str(array)
        array.reduce(str(array.first)) do |acc, value|
          acc | str(value)
        end
      end
    end
  end
end
