# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST OWMWP (Office of Weights and Measures Workshop Proceedings)
      # Examples:
      # - "NIST OWMWP 06-13-2018" - Date-based format MM-DD-YYYY
      class Owmwp < Base
        def series_code
          "OWMWP"
        end
      end
    end
  end
end