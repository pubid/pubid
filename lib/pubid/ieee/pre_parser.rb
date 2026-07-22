# frozen_string_literal: true

module Pubid
  module Ieee
    # Pre-parser for IEEE identifiers.
    #
    # Owns all regex/scan/dispatch logic that used to live on Identifier.parse.
    # Base.parse becomes a thin orchestrator that asks PreParser for a decision
    # and then routes to the right builder.
    module PreParser
      # Outcome of preprocessing an input string.
      #
      # dispatch - Symbol naming the construction strategy to use:
      #   :standard              - single identifier via parse_single
      #   :aiee_simple           - delegate to Aiee::Identifier.parse
      #   :dual_and              - split on " and " (top-level, outside parens)
      #   :dual_ampersand        - split on " & "  (top-level, outside parens)
      #   :dual_semicolon        - split on "; "
      #   :dual_space_separated  - split at second publisher occurrence
      #   :dual_reaffirmed       - (R####) (Revision of ...) collapse + reaffirm
      #   :dual_ire              - (R####) (IRE identifier) split
      #   :aiee_asa_adoption     - AIEE identifier with (ASA ...) parenthetical
      #   :adopted               - parenthetical adoption with foreign identifier
      #
      # input - the (possibly rewritten) input string to feed downstream.
      # parts - array of pre-split strings for dual/adopted dispatches.
      # metadata - hash of extracted signals (e.g. reaffirmed: "2010").
      Result = Struct.new(:dispatch, :input, :parts, :metadata, 
                          keyword_init: true) do
        def initialize(*)
          super
          self.parts ||= []
          self.metadata ||= {}
        end
      end

      PUBLISHERS = %w[IEEE AIEE ANSI ASA IEC ISO ASTM NACE NSF ASHRAE NCTA 
                      AESC].freeze
      private_constant :PUBLISHERS

      ADOPTION_PREFIXES =
        %w[ANSI ISO IEC IEEE AIEE IRE ASA ASTM CSA ASME NACE NSF ASHRAE NCTA 
           AESC].freeze
      private_constant :ADOPTION_PREFIXES

      NON_ADOPTION_KEYWORDS = %w[
        Revision Revison Amendment Corrigendum Corrigenda incorporates Incorporating
        Includes Incorporates Adoption Supplement Draft\ Amendment DRAFT\ Amendment
        Draft\ Revision Reaffirmation Redesignation redesignated\ as Supersedes
        Supercedes Includes Previously\ designated\ as Notebooks Standard\ Newspaper
      ].freeze
      private_constant :NON_ADOPTION_KEYWORDS

      class << self
        # Run every preprocessing rule against +input+ and return a Result.
        def preprocess(input)
          input = normalize_comma_separated_dual(input)

          case detect_dispatch(input)
          when :aiee_simple            then Result.new(dispatch: :aiee_simple, 
                                                       input: input)
          when :iec_ieee_copublished   then Result.new(
            dispatch: :iec_ieee_copublished, input: input,
          )
          when :dual_semicolon         then build_dual_semicolon(input)
          when :dual_reaffirmed        then build_dual_reaffirmed(input)
          when :dual_ire               then build_dual_ire(input)
          when :dual_space_separated   then build_dual_space_separated(input)
          when :dual_and               then build_dual_and(input)
          when :dual_ampersand         then build_dual_ampersand(input)
          when :aiee_asa_adoption      then build_aiee_asa_adoption(input)
          when :adopted                then build_adopted(input)
          else                              Result.new(dispatch: :standard, 
                                                       input: input)
          end
        end

        private

        # "IEEE Std 960-1989, Std 1177-1989" → "IEEE Std 960-1989 and IEEE Std 1177-1989"
        def normalize_comma_separated_dual(input)
          input.gsub(/(\d{4}),\s+Std\s/, '\1 and IEEE Std ')
        end

        # Cheap structural detection that runs before the more expensive
        # splitting / parsing attempts. Returns a dispatch symbol or nil.
        def detect_dispatch(input)
          return :aiee_simple if input.start_with?("AIEE ") && !input.include?("(")
          return :iec_ieee_copublished if input.start_with?("IEC/IEEE ")
          return :dual_semicolon if input.include?("; ")
          return :dual_reaffirmed if reaffirmed_revision_pattern?(input)
          return :dual_ire if ire_dual_pattern?(input)
          return :dual_space_separated if space_separated_dual?(input)
          return :dual_and if input.include?(" and ") && and_outside_parens?(input)
          return :dual_ampersand if input.include?(" & ") && ampersand_outside_parens?(input)
          return :aiee_asa_adoption if aiee_asa_pattern?(input)
          return :adopted if adoption_pattern?(input)

          nil
        end

        def reaffirmed_revision_pattern?(input)
          input =~ /\(R(\d{4})\)\s*\(Revision of ([^)]+)\)/ ||
            input =~ /\(Reaffirmed\s+(\d{4})\)\s*\(Revision of ([^)]+)\)/
        end

        def ire_dual_pattern?(input)
          /\(R\d{4}\)\s*\((\d+\s+IRE[^)]+)\)/.match?(input)
        end

        def space_separated_dual?(input)
          positions = publisher_positions(input).sort_by { |p| p[:pos] }
          return false if positions.length < 2

          between = input[positions[0][:pos]..(positions[1][:pos] - 1)]
          !between.include?("/") && !between.include?(" and ") && !between.include?(" & ")
        end

        def and_outside_parens?(input)
          find_top_level(input, " and ")
        end

        def ampersand_outside_parens?(input)
          find_top_level(input, " & ")
        end

        def aiee_asa_pattern?(input)
          input.match?(/^AIEE\s+/) && input.include?("(") && input.include?("ASA")
        end

        def adoption_pattern?(input)
          return false unless input.include?("(") && input.include?(")")
          return false if input.start_with?("IEC/IEEE ")

          main_part = input.split("(").first&.strip
          adoption_match = input.match(/\(([^)]+)\)/)
          adoption_part = adoption_match&.captures&.first
          return false if main_part.nil? || adoption_part.nil?

          return false if non_adoption_keyword?(adoption_part)

          adoption_part.match?(/\b(#{ADOPTION_PREFIXES.join('|')})\s/) ||
            adoption_part.match?(/^\s*(#{ADOPTION_PREFIXES.join('|')})\b/) ||
            adoption_part.match?(/\bStd\s+\d+/)
        end

        def non_adoption_keyword?(adoption_part)
          adoption_part.match?(/^\s*(#{NON_ADOPTION_KEYWORDS.join('|')})/i)
        end

        # Locate all positions where a known publisher appears at top level
        # (not nested inside parentheses).
        def publisher_positions(input)
          positions = []
          PUBLISHERS.each do |pub|
            regex = /(?:^|\s)(#{Regexp.escape(pub)})(?:\s|\/)/
            input.scan(regex) do
              match_pos = Regexp.last_match.begin(1)
              before_match = input[0...match_pos]
              next if before_match.count("(") > before_match.count(")")

              positions << { pos: match_pos, publisher: pub }
            end
          end
          positions
        end

        # Walk +input+ looking for +marker+ at paren depth zero.
        def find_top_level(input, marker)
          paren_depth = 0
          input.each_char.with_index do |char, i|
            paren_depth += 1 if char == "("
            paren_depth -= 1 if char == ")"
            return true if paren_depth.zero? && input[i..(i + marker.length - 1)] == marker
          end
          false
        end

        # ---- builders for each dispatch ----

        def build_dual_semicolon(input)
          parts = input.split("; ")
          unless parts.length == 2
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          Result.new(dispatch: :dual_semicolon, input: input,
                     parts: [parts[0].strip, parts[1].strip])
        end

        def build_dual_reaffirmed(input)
          year_match = input.match(/\((?:R|Reaffirmed\s+)(\d{4})\)\s*\(Revision of ([^)]+)\)/)
          return Result.new(dispatch: :standard, input: input) unless year_match

          year = year_match[1]
          rewritten = input.sub(
            /\((?:R|Reaffirmed\s+)\d{4}\)\s*\(Revision of ([^)]+)\)/, "(Revision of \\1)"
          )
          Result.new(dispatch: :dual_reaffirmed, input: rewritten,
                     metadata: { reaffirmed: year })
        end

        def build_dual_ire(input)
          main_part = input.split(" (R").first&.strip
          reaffirmed_match = input.match(/\(R(\d{4})\)/)
          ire_match = input.match(/\((\d+\s+IRE[^)]+)\)/)
          unless main_part && reaffirmed_match && ire_match
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          Result.new(dispatch: :dual_ire, input: input,
                     parts: [main_part, ire_match[1]],
                     metadata: { reaffirmed: reaffirmed_match[1] })
        end

        def build_dual_space_separated(input)
          positions = publisher_positions(input).sort_by { |p| p[:pos] }
          if positions.length < 2
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          first_pub = positions[0]
          second_pub = positions[1]
          between = input[first_pub[:pos]..(second_pub[:pos] - 1)]
          if between.include?("/") || between.include?(" and ")
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          split_pos = second_pub[:pos]
          split_pos -= 1 while split_pos.positive? && input[split_pos - 1] == " "

          Result.new(dispatch: :dual_space_separated, input: input,
                     parts: [input[0...split_pos].strip, input[split_pos..].strip])
        end

        def build_dual_and(input)
          position = top_level_position(input, " and ")
          return Result.new(dispatch: :standard, input: input) unless position

          Result.new(dispatch: :dual_and, input: input,
                     parts: [input[0...position].strip,
                             input[(position + 5)..].strip])
        end

        def build_dual_ampersand(input)
          parts = input.split(" & ")
          unless parts.length == 2
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          Result.new(dispatch: :dual_ampersand, input: input,
                     parts: [parts[0].strip, parts[1].strip])
        end

        def build_aiee_asa_adoption(input)
          main_part = input.split("(").first&.strip
          adoption_match = input.match(/\((ASA[^)]+)\)/)
          unless main_part && adoption_match
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          Result.new(dispatch: :aiee_asa_adoption, input: input,
                     parts: [main_part, adoption_match.captures.first])
        end

        def build_adopted(input)
          main_part = input.split("(").first&.strip
          adoption_match = input.match(/\(([^)]+)\)/)
          adoption_part = adoption_match&.captures&.first
          unless main_part && adoption_part
            return Result.new(dispatch: :standard, 
                              input: input)
          end

          Result.new(dispatch: :adopted, input: input,
                     parts: [main_part, adoption_part])
        end

        # Return the index where +marker+ first occurs at paren depth zero,
        # or nil if no such occurrence exists.
        def top_level_position(input, marker)
          paren_depth = 0
          input.each_char.with_index do |char, i|
            paren_depth += 1 if char == "("
            paren_depth -= 1 if char == ")"
            if paren_depth.zero? && input[i..(i + marker.length - 1)] == marker
              return i
            end
          end
          nil
        end
      end
    end
  end
end
