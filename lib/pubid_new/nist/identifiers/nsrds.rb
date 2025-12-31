# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS NSRDS (National Standard Reference Data Series)
      # Examples:
      # - "NBS NSRDS 1" - Basic NSRDS
      # - "NSRDS-NBS 1" - With hyphen prefix
      # - "NBS NSRDS 1p1" - With part notation
      class Nsrds < Base
        def default_publisher
          "NBS"
        end

        def series_code
          "NSRDS"
        end
      end
    end
  end
end