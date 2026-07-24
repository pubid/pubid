# frozen_string_literal: true

module Pubid
  module Ashrae
    module Identifiers
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :AddendaPackage, "#{__dir__}/identifiers/addenda_package"
      autoload :Addendum, "#{__dir__}/identifiers/addendum"
      autoload :CombinedAddenda, "#{__dir__}/identifiers/combined_addenda"
      autoload :Errata, "#{__dir__}/identifiers/errata"
      autoload :Guideline, "#{__dir__}/identifiers/guideline"
      autoload :Interpretation, "#{__dir__}/identifiers/interpretation"
      autoload :Standard, "#{__dir__}/identifiers/standard"
    end
  end
end
