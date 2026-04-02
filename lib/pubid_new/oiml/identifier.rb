# frozen_string_literal: true

require_relative "../identifier"

module PubidNew
  module Oiml
    class Identifier < PubidNew::Identifier
      def to_urn
        require_relative "urn_generator"
        UrnGenerator.new(self).generate
      end
    end
  end
end
