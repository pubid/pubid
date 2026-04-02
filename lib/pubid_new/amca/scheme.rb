# frozen_string_literal: true

require_relative "../identifier"
require_relative "../scheme"
require_relative "identifier"
require_relative "identifiers/base"
require_relative "identifiers/standard"
require_relative "identifiers/publication"
require_relative "identifiers/interpretation"

module PubidNew
  module Amca
    # Scheme class for ACMA identifier configuration
    class Scheme < PubidNew::Scheme
      def initialize
        @identifiers = [
          Identifiers::Standard,
          Identifiers::Publication,
          Identifiers::Interpretation,
        ].freeze
      end
    end
  end
end
