# frozen_string_literal: true

module Pubid
  module Bipm
    # Namespace for concrete BIPM identifier types.
    module Identifiers
      autoload :CommitteeDocument, "#{__dir__}/identifiers/committee_document"
      autoload :Meeting, "#{__dir__}/identifiers/meeting"
      autoload :MetrologiaArticle, "#{__dir__}/identifiers/metrologia_article"
      autoload :SiBrochure, "#{__dir__}/identifiers/si_brochure"
    end
  end
end
