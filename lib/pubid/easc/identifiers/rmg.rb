# frozen_string_literal: true

module Pubid
  module Easc
    module Identifiers
      # РМГ — Рекомендации по межгосударственной стандартизации
      # (Recommendations on interstate standardization). Issued by EASC.
      #
      # Examples:
      #   РМГ 151-2025
      #   РМГ 29-2013
      class Rmg < Base
        def self.type
          { key: :rmg, title: "Interstate Recommendations", series: "RMG" }
        end
      end
    end
  end
end
