# frozen_string_literal: true

module Pubid
  module Easc
    module Identifiers
      # ПМГ — Правила по межгосударственной стандартизации
      # (Rules on interstate standardization). Issued by EASC.
      #
      # Examples:
      #   ПМГ 03-2025
      #   ПМГ 126-2013
      #   ПМГ В 31-2001           (defense variant)
      class Pmg < Identifier
        def self.type
          { key: :pmg, title: "Interstate Rules", series: "PMG" }
        end
      end
    end
  end
end
