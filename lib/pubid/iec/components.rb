# frozen_string_literal: true

module Pubid
  module Iec
    module Components
      autoload :Code, "#{__dir__}/components/code"
      autoload :ConsolidatedAmendment, "#{__dir__}/components/consolidated_amendment"
      autoload :Publisher, "#{__dir__}/components/publisher"
      autoload :Sheet, "#{__dir__}/components/sheet"
      autoload :TrfInfo, "#{__dir__}/components/trf_info"
      autoload :VapSuffix, "#{__dir__}/components/vap_suffix"
    end
  end
end
