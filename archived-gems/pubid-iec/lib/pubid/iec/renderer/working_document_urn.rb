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

        def render(with_date: true, with_language_code: :iso, annotated: false,
    **args)
          render_base_identifier(**args, with_date: with_date,
                                         with_language_code: with_language_code, annotated: annotated) + @prerendered_params[:language].to_s
        end
      end
    end
  end
end
