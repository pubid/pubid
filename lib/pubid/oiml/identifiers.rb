# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Annex, "#{__dir__}/identifiers/annex"
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :BasicPublication, "#{__dir__}/identifiers/basic_publication"
      autoload :Document, "#{__dir__}/identifiers/document"
      autoload :ExpertReport, "#{__dir__}/identifiers/expert_report"
      autoload :Guide, "#{__dir__}/identifiers/guide"
      autoload :Recommendation, "#{__dir__}/identifiers/recommendation"
      autoload :SeminarReport, "#{__dir__}/identifiers/seminar_report"
      autoload :Vocabulary, "#{__dir__}/identifiers/vocabulary"
    end
  end
end
