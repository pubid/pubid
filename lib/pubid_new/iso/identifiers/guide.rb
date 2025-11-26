require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
  module Identifiers
    class Guide < SingleIdentifier
      attribute :type, Components::Type, default: -> { type[:key] }

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :pwiis,
          stage_code: :pwi,
          type_code: :guide,
          abbr: ["PWI Guide"],
          name: "Proposed Work Item for International Standard",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),
        Components::TypedStage.new(
          code: :npguide,
          stage_code: :np,
          type_code: :guide,
          abbr: ["NP Guide", "NP GUIDE"], # "NP Guide" is legacy
          name: "New Work Item Proposal for Guide",
          harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
        ),

        Components::TypedStage.new(
          code: :awiguide,
          stage_code: :awi,
          type_code: :guide,
          abbr: ["AWI Guide", "AWI GUIDE"], # "AWI Guide" is legacy
          name: "Approved Work Item for Guide",
          harmonized_stages: %w[10.99 20.00],
        ),

        Components::TypedStage.new(
          code: :wdguide,
          stage_code: :wd,
          type_code: :guide,
          abbr: ["WD Guide", "WD GUIDE"], # "WD Guide" is legacy
          name: "Working Draft for Guide",
          harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
        ),

        Components::TypedStage.new(
          code: :cdguide,
          stage_code: :cd,
          type_code: :guide,
          abbr: ["CD Guide", "CD GUIDE"], # "CD Guide" is legacy
          name: "Committee Draft for Guide",
          harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
        ),

        Components::TypedStage.new(
          code: :dguide,
          stage_code: :dguide,
          type_code: :guide,
          abbr: ["DGuide", "DGUIDE"], # DGUIDE is legacy
          name: "Draft Guide",
          harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
        ),
        Components::TypedStage.new(
          code: :fdguide,
          stage_code: :fdguide,
          type_code: :guide,
          abbr: ["FDGuide", "FD GUIDE"], # "FD GUIDE" is legacy
          name: "Final Draft Guide",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :prfguide,
          stage_code: :prf,
          type_code: :guide,
          abbr: ["PRF Guide", "PRF GUIDE"], # "PRF GUIDE" is legacy
          name: "Proof Guide",
          harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
        ),
        Components::TypedStage.new(
          code: :pubguide,
          stage_code: :published,
          type_code: :guide,
          abbr: ["Guide", "GUIDE"], # "Guide" is canonical, "GUIDE" is legacy
          name: "Published Guide",
          harmonized_stages: %w[60.00 60.60],
        ),
      ].freeze

      def self.type
        { key: :guide, title: "Guide", short: "GUIDE" }
      end

      # Override publisher_portion to use space before Guide (not slash)
      # Correct format: "ISO Guide 1" and "ISO/IEC Guide X"
      def publisher_portion(lang: :en)
        # If there are no copublishers, return publisher + space + Guide
        return [
            publisher.body,
            (typed_stage.canonical_abbreviation.empty? ? "" : " #{typed_stage.canonical_abbreviation}"),
          ].join('') unless copublishers&.any?

        # If there are copublishers, join them with slashes, then space + Guide
        [
          ([publisher] + copublishers).map(&:body).join("/"),
          (typed_stage.canonical_abbreviation.empty? ? "" : " #{typed_stage.canonical_abbreviation}"),
        ].join('')
      end

      # TODO: Support French and Russian
      # if opts[:language] == :french
      #   "Guide %{publisher}%{stage} %{number}%{part}%{iteration}%{year}%{amendments}%{corrigendums}%{edition}" % params
      # elsif opts[:language] == :russian
      #   "Руководство %{publisher}%{stage} %{number}%{part}%{iteration}%{year}%{amendments}%{corrigendums}%{edition}" % params
      # else
      #   if params[:stage] && params[:stage].is_a?(Pubid::Core::TypedStage)
      #     "%{publisher}%{stage} %{number}%{part}%{iteration}%{year}%{amendments}%{corrigendums}%{edition}" % params
      #   else
      #     "%{publisher}%{stage} Guide %{number}%{part}%{iteration}%{year}%{amendments}%{corrigendums}%{edition}" % params
      #   end
      # end

      # def to_s(lang: :en)
      #   [
      #     base_identifier.to_s,
      #     "/#{typed_stage.abbreviation}",
      #     number_portion
      #   ].join('')
      # end
    end
  end
end
end