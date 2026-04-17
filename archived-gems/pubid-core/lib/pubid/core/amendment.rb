module Pubid
  module Core
    class Amendment < Supplement
      def render_pubid
        stage = render_pubid_stage
        stage += " " unless stage.empty?
        "/#{stage}Amd #{render_pubid_number}"
      end

      def render_urn
        "#{render_urn_stage}:amd#{render_urn_number}"
      end
    end
  end
end
