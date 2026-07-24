# frozen_string_literal: true

module Pubid
  module Itu
    module Components
      autoload :Sector, "#{__dir__}/components/sector"
      autoload :Series, "#{__dir__}/components/series"
      autoload :Code, "#{__dir__}/components/code"
      autoload :Designation, "#{__dir__}/components/designation"
    end
  end
end
