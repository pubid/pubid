# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # ГОСТ (bare) — interstate standard. Issued by МГС
      # (Межгосударственный совет по стандартизации).
      #
      # Examples:
      #   ГОСТ 14946-82           (dated)
      #   ГОСТ 2.312              (undated)
      #   ГОСТ ISO 9692-1         (copublisher + part, undated)
      class InterstateStandard < Identifier
        def self.type
          { key: :"interstate-standard", title: "Interstate Standard", short: nil }
        end
      end
    end
  end
end
