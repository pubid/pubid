# frozen_string_literal: true

module Pubid
  module FormatDetector
    URN_PATTERN = /\Aurn:/i
    MR_STRING_PATTERN = /\A[A-Z]{2,}[.-]/

    def self.detect(string)
      case string
      when URN_PATTERN then :urn
      when MR_STRING_PATTERN then :mr_string
      else :human
      end
    end
  end
end
