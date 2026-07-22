# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      autoload :Advice,           "#{__dir__}/identifiers/advice"
      autoload :Annex,            "#{__dir__}/identifiers/annex"
      autoload :Standard,         "#{__dir__}/identifiers/standard"
      autoload :Recommendation,   "#{__dir__}/identifiers/recommendation"
      autoload :Guideline,        "#{__dir__}/identifiers/guideline"
      autoload :Manual,           "#{__dir__}/identifiers/manual"
      autoload :ModelCourse,      "#{__dir__}/identifiers/model_course"
      autoload :GeneralAssembly,  "#{__dir__}/identifiers/general_assembly"
      autoload :Letter,           "#{__dir__}/identifiers/letter"
      autoload :Report,           "#{__dir__}/identifiers/report"
      autoload :Resolution,       "#{__dir__}/identifiers/resolution"
    end
  end
end
