# frozen_string_literal: true

module Pubid
  module Iec
    class Parser
      DASH_CHARS = ["-", "‑", "‐"].freeze

      IEV_SHORTHAND = /\AIEV(?=\z|[\s-])/

      # Pre-parse ingestion normalizations (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(input)
        # Normalize tab-separated editions: "IECEE AD-001\tED1.6" -> "IECEE AD-001 ED1.6"
        normalized = input.gsub("\t", " ")
        # Normalize comma-separated editions: "IEC CAB-G01:2025-02, Ed. 2.1" -> "IEC CAB-G01:2025-02 Ed. 2.1"
        normalized = normalized.gsub(/,\s+Ed\./, " Ed.")
        # Expand IEV shorthand: "IEV" / "IEV-351" -> "IEC 60050" / "IEC 60050-351"
        normalized.sub(IEV_SHORTHAND, "IEC 60050")
      end
    end
  end
end
