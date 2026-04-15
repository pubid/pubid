module Pubid
  module Iec
    module Renderer
      class WorkingDocumentUrn < Urn
        def render_identifier(params)
          "urn:iec:working-document:%<technical_committee>s:%<number>s%<stage>s" % params
        end

        def render_technical_committee(technical_committee, _opts, _params)
          technical_committee.to_s.gsub("/", "-").downcase
        end

        def render_stage(stage, _opts, _params)
          ":stage-#{stage.to_s.downcase}"
        end
      end
    end
  end
end
