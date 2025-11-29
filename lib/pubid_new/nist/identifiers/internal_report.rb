# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Internal Report (IR) / NISTIR
      # Examples:
      # - "NIST IR 8115" = Internal Report 8115
      # - "NIST IR 8115r1" = Internal Report 8115 revision 1
      # - "NBS IR 73-197" = NBS Internal Report 73-197
      class InternalReport < Base
        def series_code
          "IR"
        end
      end
    end
  end
end