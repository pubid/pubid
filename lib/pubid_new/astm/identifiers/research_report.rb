# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class ResearchReport < Base
        attribute :committee, :string # A01, C09

        def to_s
          parts = []
          parts << publisher if publisher
          parts << "RR:#{committee}-#{code.number}" if committee && code
          parts.join(" ")
        end
      end
    end
  end
end
