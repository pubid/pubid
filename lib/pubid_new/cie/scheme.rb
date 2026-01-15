# frozen_string_literal: true

require_relative "../scheme"
require_relative "identifiers/standard"
require_relative "identifiers/conference"
require_relative "identifiers/corrigendum"
require_relative "identifiers/bundle"
require_relative "identifiers/dual_published"
require_relative "identifiers/identical"
require_relative "identifiers/joint_published"
require_relative "identifiers/supplement"
require_relative "identifiers/tutorial_bundle"

module PubidNew
  module Cie
    class Scheme < PubidNew::Scheme
      def initialize
        @identifiers = [
          Identifiers::Standard,
          Identifiers::Conference,
          Identifiers::Corrigendum,
          Identifiers::Bundle,
          Identifiers::DualPublished,
          Identifiers::Identical,
          Identifiers::JointPublished,
          Identifiers::Supplement,
          Identifiers::TutorialBundle,
        ].freeze
      end
    end
  end
end
