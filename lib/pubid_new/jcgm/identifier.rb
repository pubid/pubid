# frozen_string_literal: true

require_relative "../identifier"

module PubidNew
  module Jcgm
    class Identifier < ::PubidNew::Identifier
      def self.parse(string)
        PubidNew::Jcgm.parse(string)
      end
    end
  end
end