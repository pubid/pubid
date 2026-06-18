# frozen_string_literal: true

module Pubid
  module Amca
    module Identifiers
      # Publication identifier for ACMA publications
      # Examples:
      # - AMCA Publication 211-22 (Rev. 01-23)
      # - AMCA Publication 311-16
      # - AMCA Publication 1011-03 (R2010)
      class Publication < Base
        attr_reader :revision

        def initialize(code:, year:, copublisher: nil, suffix: nil,
reaffirmed: nil, revision: nil)
          @code = Components::Code.new(value: code.to_s)
          @year = Components::Date.new(year: year.to_s) if year
          @copublisher = copublisher
          @suffix = suffix
          @reaffirmed = reaffirmed
          @revision = revision
        end

        def self.type
          { key: :publication, title: "Publication", short: nil }
        end

        def type
          Publication.type
        end
      end
    end
  end
end
