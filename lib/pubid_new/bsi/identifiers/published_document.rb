# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Published Document (PD) identifier
      class PublishedDocument < Base
        def publisher
          stage == "DD" ? "DD" : "PD"
        end
      end
    end
  end
end