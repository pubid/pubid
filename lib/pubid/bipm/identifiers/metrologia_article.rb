# frozen_string_literal: true

module Pubid
  module Bipm
    module Identifiers
      # A Metrologia journal reference, at volume, volume+issue, or
      # volume+issue+article granularity. Issue may be alphanumeric ("1A") and
      # the article keeps its printed form ("06007", "S138").
      #
      # Printed forms (all round-trip):
      #   "Metrologia 51"          volume only
      #   "Metrologia 1 1"         volume + issue
      #   "Metrologia 51 1 128"    volume + issue + article
      class MetrologiaArticle < Identifier
        GROUP = "Metrologia"

        def self.type
          { key: :metrologia_article, web: :metrologia_article,
            title: "Metrologia Article", short: "metrologia-article" }
        end
      end
    end
  end
end
