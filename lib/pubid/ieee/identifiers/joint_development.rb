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

          # ISO stage code (only if this was originally ISO-led)
          # For IEEE-led conversions, we skip the stage since we don't have ISO equivalent
          if lead_party == "ISO" && (typed_stage || iso_stage)
            if typed_stage
              parts << typed_stage.to_iso_format
            elsif iso_stage
              parts << iso_stage
            end
          end

          # IEEE semantics: P = project (a draft); no P = a standard. The
          # P-state is identity-bearing and prints as spelled — it is never
          # added or stripped here.
          code_str = code.to_s
          code_str += mark unless code_str.empty?
          parts << code_str if code_str && !code_str.empty?

          # Join with space and add year with colon; the joint stage-draft
          # clause ("D=WD.5") rides after the year in the ISO-led print.
          result = parts.join(" ")
          result += ":#{year}" if year
          result += "/#{ieee_draft}" if ieee_draft && ieee_draft.start_with?("D=")
          # Only the language/edition marker ("(E)", "(E/F)") prints; a
          # trailing relationship narrative is metadata, not identity.
          if parenthetical_content&.match?(%r{\A[A-Z](?:\s*[/&]\s*[A-Z])*\z})
            result += " (#{parenthetical_content})"
          end

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

          # Add IEEE draft notation if available (e.g., /D8)
          if ieee_draft
            code_str += "/#{ieee_draft}"
          elsif typed_stage&.ieee_draft_equivalent
            code_str += "/#{typed_stage.ieee_draft_equivalent}"
          end

          parts << code_str if code_str && !code_str.empty?

          # Join with space and add year with dash
          result = parts.join(" ")
          result += "-#{year}" if year

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
