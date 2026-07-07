# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      autoload :Base,           "#{__dir__}/identifiers/base"
      autoload :Standard,       "#{__dir__}/identifiers/standard"
      autoload :Recommendation, "#{__dir__}/identifiers/recommendation"
      autoload :Guideline,      "#{__dir__}/identifiers/guideline"
      autoload :Manual,         "#{__dir__}/identifiers/manual"
      autoload :ModelCourse,    "#{__dir__}/identifiers/model_course"
      autoload :Report,         "#{__dir__}/identifiers/report"
      autoload :Resolution,     "#{__dir__}/identifiers/resolution"
    end
  end
end
