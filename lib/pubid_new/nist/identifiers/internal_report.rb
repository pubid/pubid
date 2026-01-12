# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Interagency Report (IR) / NISTIR
      # Examples:
      # - "NIST IR 8115" = Interagency Report 8115
      # - "NIST IR 8115r1" = Interagency Report 8115 revision 1
      # - "NBS IR 73-197" = NBS Interagency Report 73-197
      class InteragencyReport < Base
        def series_code
          "IR"
        end
      end
    end
  end
end
