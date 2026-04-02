# frozen_string_literal: true

module Pubid
  module Amca
    # Scheme class for ACMA identifier configuration
    class Scheme < Pubid::Scheme
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
