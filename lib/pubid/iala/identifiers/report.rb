# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Reports & Proceedings (X prefix, planned).
      # Today reports carry no code; X is reserved for future numbered
      # reports.
      class Report < Base
        def self.type
          { key: :report, title: "Report", short: "X" }
        end
      end
    end
  end
end
