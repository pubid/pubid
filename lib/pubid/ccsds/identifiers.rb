# frozen_string_literal: true

module Pubid
  module Ccsds
    module Identifiers
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
    end
  end
end