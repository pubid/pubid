# frozen_string_literal: true

module Pubid
  module Etsi
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :EtsiStandard, "#{__dir__}/identifiers/etsi_standard"
      autoload :SupplementIdentifier,
               "#{__dir__}/identifiers/supplement_identifier"
    end
  end
end
