# frozen_string_literal: true

module Pubid
  module W3c
    module Identifiers
      autoload :Standard, "#{__dir__}/identifiers/standard"
      autoload :Note, "#{__dir__}/identifiers/note"
      autoload :DraftNote, "#{__dir__}/identifiers/draft_note"
      autoload :WorkingDraft, "#{__dir__}/identifiers/working_draft"
      autoload :CandidateRecommendation,
               "#{__dir__}/identifiers/candidate_recommendation"
      autoload :CandidateRecommendationDraft,
               "#{__dir__}/identifiers/candidate_recommendation_draft"
      autoload :Recommendation, "#{__dir__}/identifiers/recommendation"
      autoload :ProposedRecommendation,
               "#{__dir__}/identifiers/proposed_recommendation"
      autoload :ProposedEditedRecommendation,
               "#{__dir__}/identifiers/proposed_edited_recommendation"
      autoload :SupersededRecommendation,
               "#{__dir__}/identifiers/superseded_recommendation"
      autoload :ObsoleteRecommendation,
               "#{__dir__}/identifiers/obsolete_recommendation"
    end
  end
end
