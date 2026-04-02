# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Bundled, "#{__dir__}/identifiers/bundled"
      autoload :CanadianAdopted, "#{__dir__}/identifiers/canadian_adopted"
      autoload :Cec, "#{__dir__}/identifiers/cec"
      autoload :Combined, "#{__dir__}/identifiers/combined"
      autoload :CsaAdopted, "#{__dir__}/identifiers/csa_adopted"
      autoload :Package, "#{__dir__}/identifiers/package"
      autoload :Series, "#{__dir__}/identifiers/series"
      autoload :Standard, "#{__dir__}/identifiers/standard"
    end
  end
end
