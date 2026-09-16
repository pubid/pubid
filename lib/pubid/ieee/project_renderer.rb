# frozen_string: true

module Pubid
  module Ieee
    # Renders the IEEE PROJECT DESIGNATOR — the short form IEEE itself uses
    # for draft documents ("P1201/D0.3", "P10000/D1.2"): the project marker,
    # the number with its parts, and the draft. No publisher, no type word,
    # no date (pubid#18: metanorma-ieee builds these for drafts and had to
    # post-process the full rendering).
    class ProjectRenderer
      def initialize(id)
        @id = id
      end

      def render(context: nil, **_opts)
        id = @id
        body = if id.respond_to?(:code_obj) && id.code_obj
                 id.code_obj.to_s
               else
                 id.number.to_s
               end
        body = "P#{body}" if project?(id) && !body.start_with?("P")

        draft = id.draft_obj if id.respond_to?(:draft_obj)
        body += "/D#{draft.version}" if draft&.version

        body
      end

      private

      # A project identifier carries its marker in one of three places
      # depending on which grammar path built it: the code prefix (the bare
      # "P1201/D0.3" spelling), the "P" type code ("IEEE P802.16/D-3"), or a
      # typed stage with project_status (the D1-D6 draft stages).
      def project?(id)
        return true if id.code_obj&.prefix.to_s == "P"
        return true if id.type.to_s == "P"

        id.respond_to?(:typed_stage) &&
          id.typed_stage&.respond_to?(:project_status) &&
          id.typed_stage.project_status
      end
    end
  end
end
