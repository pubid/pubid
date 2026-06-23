# frozen_string_literal: true

module Pubid
  module Nist
    module Components
      autoload :Code, "#{__dir__}/components/code"
      autoload :Edition, "#{__dir__}/components/edition"
      autoload :IssueNumber, "#{__dir__}/components/issue_number"
      autoload :Part, "#{__dir__}/components/part"
      autoload :Stage, "#{__dir__}/components/stage"
      autoload :Supplement, "#{__dir__}/components/supplement"
      autoload :Translation, "#{__dir__}/components/translation"
      autoload :Update, "#{__dir__}/components/update"
      autoload :Version, "#{__dir__}/components/version"
      autoload :Volume, "#{__dir__}/components/volume"
    end
  end
end
