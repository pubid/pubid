# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Handles ISO/IEC/IEEE joint development identifiers
      # Supports bidirectional format conversion between IEEE and ISO representations
      #
      # Joint development standards can be represented in two formats based on lead party:
      #
      # IEEE-led Format (lead_party: "IEEE"):
      #   ISO/IEC/IEEE P26511/D8-2018
      #   - Publishers: ISO/IEC/IEEE (slash-separated)
      #   - Lead party: IEEE (drives development)
      #   - P prefix indicates IEEE project (draft)
      #   - /D8 indicates IEEE draft notation
      #   - Dash before year
      #
      # ISO-led Format (lead_party: "ISO"):
      #   ISO/IEC/IEEE FDIS 26511:2018
      #   - Publishers: ISO/IEC/IEEE (slash-separated)
      #   - Lead party: ISO (drives development)
      #   - ISO stage code (FDIS) instead of P/D notation
      #   - Colon before year
      #
      # Key principles:
      # - Lead party determines canonical format
      # - NO equivalence mapping (as per IEEE staff guidance)
      # - "P" prefix means IEEE project (any stage)
      # - ISO stages and IEEE drafts can coexist but are not equivalent
      # - Format conversion preserves semantic meaning within each system
      class JointDevelopment < Identifier
        # Split index columns (number/prefix/parts/separator) instead of a
        # `code` string, like every IEEE leaf — see CodeNumber. Rendering reads
        # `code` (base #code → code_obj), which CodeNumber rebuilds from the
        # split fields, so to_ieee_format / to_iso_format are unaffected.
        include CodeNumber

        attribute :publishers, :string, collection: true
        attribute :lead_party, :string              # "IEEE", "ISO", "IEC", etc.
        attribute :typed_stage, Components::TypedStage
        attribute :year, :string
        attribute :iso_stage, :string               # For ISO stage if present
        attribute :ieee_draft, :string              # For IEEE P/D notation if present
        attribute :parenthetical_content, :string   # e.g. the "(E)" edition
                                                    # marker of an ISO/IEC label

        # Accepts keyword args or a single positional hash (the base
        # #exclude/matching rebuild passes the latter) — see
        # Identifier#initialize.
        def initialize(args = {}, **kwargs)
          args = args.merge(kwargs) unless kwargs.empty?
          # Call super FIRST to initialize Lutaml::Model attributes
          super(args)

          # Then handle typed_stage
          if args[:typed_stage].is_a?(Components::TypedStage)
            self.typed_stage = args[:typed_stage]
          end

          # Set publishers
          if args[:publishers]
            self.publishers = args[:publishers]
          elsif args[:publisher] && args[:copublisher]
            # Combine publisher and copublisher into publishers array
            self.publishers = [args[:publisher], *args[:copublisher]].compact
          end

          # Set lead_party if not provided - default to first publisher
          if args[:lead_party]
            self.lead_party = args[:lead_party]
          elsif publishers && !publishers.empty?
            # Lead party defaults to first publisher if not explicitly set
            # Builder should override this with detected lead party
            self.lead_party = publishers.first
          end
        end

        # Canonical format based on lead party
        # @return [Symbol] :ieee or :iso
        def canonical_format
          # A PARSED stage-tracked D= designator is IEEE draft notation —
          # its canonical face is the designator spelling (§1.3 spelling 7:
          # "JOINT PNUMBER/D=<STAGE>[:year]"). Rows that carry an ISO stage
          # word (from_hash, or stage-led parses) keep the stage-word face
          # no matter what the render derives: their published spelling is
          # "IEEE FCD 15026.3:2010", not a designator (#477).
          if ieee_draft.to_s.start_with?("D=") && iso_stage.to_s.empty?
            return :ieee
          end
          # A stage-word row (parsed stage-led spelling, or a serialized
          # row carrying iso_stage) prints the stage-word face whatever
          # the lead party — the stage word is the printed identity
          # ("IEEE FCD 15026.3:2010", #477).
          return :iso unless iso_stage.to_s.empty?

          case lead_party
          when "IEEE", "AIEE"
            :ieee
          when "ISO", "IEC"
            :iso
          else
            :ieee # default to IEEE format
          end
        end

        # Convert to string representation
        # JointDevelopment has its own dual-format logic (IEEE vs ISO)
        # that doesn't go through the format registry renderer.
        # @param format [Symbol] :ieee or :iso (defaults to canonical_format)
        # @param trademark [Boolean] append the IEEE trademark symbol (™/®)
        # @return [String] formatted identifier
        # `**_opts` absorbs render flags this list does not name (`annotated:`),
        # which the closed keyword list used to reject outright.
        def to_s(format: canonical_format, trademark: false, **opts)
          # The mark goes after the code number, before the draft and the year
          # ("ISO/IEC/IEEE P26511™/D8-2018"), so it is threaded into the
          # format builders rather than appended to the finished string.
          mark = if trademark
                   Pubid::Ieee.trademark_symbol_for(code&.number,
                                                    code&.prefix,
                                                    publishers: publishers)
                 else
                   ""
                 end

          result = case format
                   when :iso
                     to_iso_format(mark)
                   else
                     to_ieee_format(mark)
                   end

          annotate_plain_render(result, **opts)
        end

        private

        # Convert to ISO format representation
        # ISO/IEC/IEEE FDIS 26511:2018
        # @return [String] ISO format string
        def to_iso_format(mark = "")
          parts = []

          # Publishers (slash-separated)
          parts << publishers.join("/") if publishers && !publishers.empty?

          # The stage word is the ISO format's own position convention —
          # it prints whenever the identifier carries one, regardless of
          # lead party (the format face decides, not the arrangement). A
          # stage-tracked D= designator decomposes into its stage word
          # and date ("D=CD.2-2020" → "CD2", 2020); the iteration glues
          # onto the word only for the stages whose printed ISO spellings
          # carry it (CD2, DIS2 — the grammar's multi-digit families);
          # the P project stage is IEEE convention and never prints here.
          # The stage word prints verbatim: parsed digit-suffixed
          # spellings ("CD4") are normalized to the bare word with the
          # iteration carried separately at build time, while serialized
          # rows keep the full "DIS2" — both must round-trip (#477).
          stage_word = iso_stage
          stage_word = nil if stage_word.to_s.empty?
          # A serialized row's stage iteration is identity: re-attach it
          # to the printed word ("DIS2 24748.4:2015", #477). The parse
          # path never sets stage_iteration for digit-suffixed spellings.
          iter = stage_iteration.respond_to?(:number) ? stage_iteration.number : stage_iteration
          stage_word = "#{stage_word}#{iter}" if stage_word && iter.to_s.match?(/\A\d+\z/)
          draft_year = nil
          if stage_word.nil? &&
             ieee_draft.to_s.match(/\AD=([A-Z]+)(?:\.(\d+[a-z]?))?(?:[-:](\d{4}))?\z/)
            stage_word = Regexp.last_match(1)
            draft_year = Regexp.last_match(3)
          end
          parts << stage_word if stage_word

          # The P project marker is identity-bearing and prints on both
          # faces (the standing trademark_leaf_to_s_spec contract:
          # "ISO/IEC/IEEE P26511:2018").
          code_str = code.to_s
          code_str += mark unless code_str.empty?
          parts << code_str if code_str && !code_str.empty?

          # Join with space and add year with colon (the ISO position
          # convention; a decomposed D= date rides here as the year).
          result = parts.join(" ")
          result += ":#{year || draft_year}" if year || draft_year
          # Only the language/edition marker ("(E)", "(E/F)") prints; a
          # trailing relationship narrative is metadata, not identity.
          if parenthetical_content&.match?(%r{\A[A-Z](?:\s*[/&]\s*[A-Z])*\z})
            result += " (#{parenthetical_content})"
          end

          # The revision narrative prints after the code: published joint
          # rows carry it as identity spelling ("…:2012(E) Revision of
          # IEEE Std C37.082-1982", #477).
          result += " #{relationships.map(&:to_s).join(' ')}" if relationships && !relationships.empty?

          result
        end

        # Convert to IEEE format representation
        # ISO/IEC/IEEE P26511/D8-2018
        # @return [String] IEEE format string
        def to_ieee_format(mark = "")
          parts = []

          # Publishers (slash-separated)
          parts << publishers.join("/") if publishers && !publishers.empty?

          # Build code part — the P-state prints as spelled (P = project
          # draft; no P = standard). Never added or stripped.
          code_str = code.to_s

          # Mark after the number, before the draft and the year
          code_str += mark unless code_str.empty?

          # Add IEEE draft notation if available (e.g., /D8). An ISO stage
          # word renders in IEEE's stage-tracked position as the ordinal-less
          # stage draft (docs/IEEE-DRAFT-STAGES.md §1.3, spelling 7):
          # "IEEE/ISO/IEC CD P42010:2020" → "IEEE/ISO/IEC P42010/D=CD-2020".
          # The iso_stage branch is checked FIRST — the typed_stage registry
          # lookup for a stage word answers a draft-equivalent ordinal ("D2"),
          # which is not the canonical stage-tracked spelling.
          if ieee_draft.to_s.start_with?("D=") && year
            # The ordinal-less stage draft's canonical face (the
            # UpdateCodes rewrite): the publication year colon-joins the
            # code and the designator trails — "P16326:2017/D=WD.5".
            code_str += ":#{year}"
            code_str += "/#{ieee_draft}"
            @designator_carries_year = true
          elsif ieee_draft
            code_str += "/#{ieee_draft}"
          elsif iso_stage
            # A stage word never converts to a designator on the IEEE
            # face: published stage rows print the stage-word face
            # ("IEEE FCD 15026.3:2010", #477).
          elsif typed_stage&.ieee_draft_equivalent
            code_str += "/#{typed_stage.ieee_draft_equivalent}"
          end

          parts << code_str if code_str && !code_str.empty?

          # Join with space and add year with dash — unless the D=
          # designator face already carried it above.
          result = parts.join(" ")
          result += "-#{year}" if year && !@designator_carries_year

          result
        end

        # Public again: these override base accessors and MUST be public — lutaml
        # serialization calls `public_send(:publisher)`, so leaving them under the
        # `private` above made JointDevelopment#to_hash raise (it could not be
        # serialized or round-tripped / indexed at all).
        public

        # Override to ensure proper publisher handling
        def publisher
          publishers&.first || super
        end

        # Override to ensure proper copublisher handling
        def copublisher
          publishers&.drop(1) || super
        end

        # `publisher`/`copublisher` are *derived* from `publishers` (the source
        # of truth, which IS serialized). Emitting them too breaks the canonical
        # round-trip: the derived `publisher` is default-omitted on the parse
        # path but re-emitted after from_hash (the override returns
        # publishers.first, not the default). Drop both — publishers rebuilds
        # them. (JointDevelopment is a top-level root, never nested, so a
        # to_hash-level drop is sufficient.)
        def to_hash(*args)
          hash = super
          if hash.is_a?(::Hash)
            hash.delete("publisher")
            hash.delete("copublisher")
          end
          hash
        end
      end
    end
  end
end
