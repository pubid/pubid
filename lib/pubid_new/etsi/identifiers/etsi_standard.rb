# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Etsi
    module Identifiers
      # Single class for all ETSI standard types
      # Type is passed as parameter: EN, ES, EG, TS, ETR, ETS, I-ETS, TBR, TCRTR, NET, GR, GS, SR, TR, GTS
      # Format: ETSI TYPE CODE VERSION (DATE)
      # Examples:
      #   ETSI GS ZSM 012 V1.1.1 (2022-12)
      #   ETSI GR ZSM 009-3 V1.1.1 (2023-08)
      #   ETSI GTS GSM 02.01 V5.5.0 (1999-01)
      class EtsiStandard < Base
        # Type is stored in @type attribute from Base
        # All rendering handled by Base class
      end
    end
  end
end