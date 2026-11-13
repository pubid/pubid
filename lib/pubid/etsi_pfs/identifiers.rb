module Pubid
  module EtsiPfs
    module Identifiers
            autoload :Standard, "#{__dir__}/identifiers/standard"
            autoload :Supplement, "#{__dir__}/identifiers/supplement"
            autoload :Amendment, "#{__dir__}/identifiers/amendment"
            autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
    end
  end
end
