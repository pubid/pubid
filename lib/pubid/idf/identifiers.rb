# frozen_string_literal: true

module Pubid
  module Idf
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :InternationalStandard, "#{__dir__}/identifiers/international_standard"
      autoload :ReviewedMethod, "#{__dir__}/identifiers/reviewed_method"
    end
  end
end