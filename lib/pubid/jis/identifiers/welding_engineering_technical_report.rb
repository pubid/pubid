# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # WES technical report. The type token follows the WES root.
      # Example: WES TR 2032:2024
      class WeldingEngineeringTechnicalReport < WeldingEngineeringStandard
        WES_TYPE = "TR"
      end
    end
  end
end
