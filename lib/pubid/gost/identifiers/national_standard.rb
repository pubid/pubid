# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # ГОСТ Р — Russian national standard. Issued by Росстандарт.
      #
      # Examples:
      #   ГОСТ Р 71039-2023                   (dated)
      #   ГОСТ Р МЭК 60794-1-23-2017         (copublisher, dated)
      #   ГОСТ Р ИСО/МЭК МФС 10609-9-95      (compound copublisher + subtype)
      class NationalStandard < Base
        def self.type
          { key: :"national-standard", title: "National Standard", short: "R" }
        end
      end
    end
  end
end
