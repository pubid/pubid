# frozen_string_literal: true

module Pubid
  module Wmo
    # Grammar for WMO identifiers.
    #
    # Accepts every attested shape (pubid#763 widened):
    #
    #   WMO-No. 1364
    #   WMO-No. 1364, 2025 edition
    #   WMO-No. 1364 2025 edition
    #   WMO-No. 1364:ed2025
    #   WMO-No. 8, Volume I / Volume I.1 / Volume D
    #   WMO-No. 306, Volume I.1, 2020 edition
    #   WMO-No. 8, 2021/2018 edition
    #   WMO-No. 1364, 2023 edition, updated in 2025
    #   WMO-No. 8, Provisional 2026 edition
    #   WMO/TD-No. 196
    #   JCOMM Technical Report No. 14
    #   GAW Report No. 312
    #   S-411
    #   S-411 1.2.1
    #   S-411:ed1.2.1
    #   S-411 Annex A
    #
    # The runtime is the baked artifact (data/parg/wmo.json, the
    # grammar of record in pubid-grammar/grammars/wmo.parg); this class
    # documents the accepted shapes.
    class Parser
    end
  end
end
