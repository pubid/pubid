# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Special Publication (SP)
      # Examples:
      # - "NIST SP 800-53" = Special Publication 800-53
      # - "NIST SP 800-53r5" = Special Publication 800-53 revision 5
      # - "NIST SP 800-57pt1r4" = Special Publication 800-57 part 1 revision 4
      class SpecialPublication < Base
        def series_code
          "SP"
        end
      end
    end
  end
end
