# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # WES technical specification. The type token follows the WES root.
      # Examples: WES TS 2816:2015, WES TS 2816(E):2015
      class WeldingEngineeringTechnicalSpecification <
            WeldingEngineeringStandard
        WES_TYPE = "TS"
      end
    end
  end
end
