# frozen_string_literal: true

# Pattern documentation generator for PubID flavors.
# Reads identifier types, typed stages, and fixtures to produce markdown docs.
module Pubid
  module Core
    class PatternDocGenerator
      attr_reader :flavor

      FLAVOR_NAMES = {
        "iso" => "ISO (International Organization for Standardization)",
        "iec" => "IEC (International Electrotechnical Commission)",
        "ieee" => "IEEE (Institute of Electrical and Electronics Engineers)",
        "nist" => "NIST (National Institute of Standards and Technology)",
        "cen" => "CEN (European Committee for Standardization)",
        "bsi" => "BSI (British Standards Institution)",
        "ccsds" => "CCSDS (Consultative Committee for Space Data Systems)",
        "itu" => "ITU (International Telecommunication Union)",
        "etsi" => "ETSI (European Telecommunications Standards Institute)",
        "jis" => "JIS (Japanese Industrial Standards)",
        "plateau" => "PLATEAU (Japanese urban planning standards)",
        "asme" => "ASME (American Society of Mechanical Engineers)",
        "astm" => "ASTM (ASTM International)",
        "ashrae" => "ASHRAE (American Society of Heating, Refrigerating and Air-Conditioning Engineers)",
        "api" => "API (American Petroleum Institute)",
        "cie" => "CIE (International Commission on Illumination)",
        "csa" => "CSA (Canadian Standards Association)",
        "idf" => "IDF (International Dairy Federation)",
        "oiml" => "OIML (International Organization of Legal Metrology)",
        "jcgm" => "JCGM (Joint Committee for Guides in Metrology)",
        "sae" => "SAE (SAE International)",
        "amca" => "AMCA (Air Movement and Control Association)",
        "ansi" => "ANSI (American National Standards Institute)",
      }.freeze

      def initialize(flavor)
        @flavor = flavor
      end

      def generate
        lines = []
        lines << "# #{flavor_upcase} Identifier Patterns"
        lines << ""
        lines << flavor_description
        lines << ""
        lines << "## Entry Point"
        lines << ""
        lines << "```ruby"
        lines << "require 'pubid/#{flavor}'"
        lines << "id = Pubid::#{flavor.capitalize}.parse(\"...\")"
        lines << "```"
        lines << ""

        identifier_types = collect_identifier_types
        if identifier_types.any?
          lines << "## Identifier Types"
          lines << ""

          identifier_types.each do |type_name, type_info|
            lines << "### #{type_name}"
            lines << ""
            lines << "**Class:** `#{type_info[:class_path]}`"
            lines << ""

            if type_info[:typed_stages].any?
              lines << "#### Typed Stages"
              lines << ""
              lines << stage_table(type_info[:typed_stages])
              lines << ""
            end
          end
        end

        fixtures = collect_fixtures
        if fixtures.any?
          lines << "## Examples"
          lines << ""
          lines << fixture_table(fixtures)
          lines << ""
        end

        urn_gen = has_urn_generator?
        lines << "## URN Support"
        lines << ""
        lines << urn_gen ? "Yes - `id.to_urn` generates URN output." : "No URN generator defined."
        lines << ""

        update_codes = has_update_codes?
        lines << "## Pre-parse Normalization"
        lines << ""
        lines << if update_codes
                   "See `data/#{flavor}/update_codes.yaml` for legacy format mappings."
                 else
                   "No normalization rules defined."
                 end
        lines << ""

        lines.join("\n")
      end

      def collect_identifier_types
        types = {}
        idents_dir = File.join(__dir__, "..", "..", "pubid", flavor,
                               "identifiers")

        return types unless Dir.exist?(idents_dir)

        Dir.glob(File.join(idents_dir, "*.rb")).each do |f|
          type_name = File.basename(f, ".rb").gsub("_",
                                                   " ").split.map(&:capitalize).join(" ")
          class_path = "Pubid::#{flavor.capitalize}::Identifiers::#{type_name.gsub(
            ' ', ''
          )}"

          typed_stages = extract_typed_stages(f)

          types[type_name] = {
            class_path: class_path,
            typed_stages: typed_stages,
          }
        end

        types
      rescue StandardError
        types
      end

      def has_urn_generator?
        File.exist?(File.join(__dir__, "..", "..", "pubid", flavor,
                              "urn_generator.rb"))
      end

      def has_update_codes?
        File.exist?(File.join(__dir__, "..", "..", "..", "data", flavor,
                              "update_codes.yaml"))
      end

      private

      def flavor_upcase
        flavor.upcase
      end

      def flavor_description
        FLAVOR_NAMES[flavor] || "#{flavor.upcase} identifiers"
      end

      def extract_typed_stages(file_path)
        content = File.read(file_path)
        stages = []

        # Find the TYPED_STAGES constant block
        return stages unless /TYPED_STAGES\s*=\s*\[/.match?(content)

        # Extract everything from TYPED_STAGES = [ to the matching ].freeze or end of array
        # Use a simpler approach: scan between TYPED_STAGES = [ and ].freeze
        start_idx = content.index(/TYPED_STAGES\s*=\s*\[/)
        return stages unless start_idx

        # Find the matching closing bracket
        bracket_count = 0
        end_idx = nil
        content[start_idx..].each_char.with_index do |char, i|
          case char
          when "["
            bracket_count += 1
          when "]"
            bracket_count -= 1
            if bracket_count.zero?
              end_idx = start_idx + i
              break
            end
          end
        end

        return stages unless end_idx

        stage_block = content[start_idx..end_idx]

        # Match TypedStage.new( ... ) including multiline
        stage_block.scan(/(?:Pubid::Components::)?TypedStage\.new\((.*?)\)/m).each do |match|
          stage_text = match.first
          name = extract_kw_arg(stage_text, "name")
          abbr = extract_kw_arg(stage_text, "abbr")
          stage_code = extract_kw_arg(stage_text, "stage_code")
          harmonized = extract_kw_arg(stage_text, "harmonized_stages")

          if name || abbr
            stages << {
              name: name,
              abbr: abbr,
              stage_code: stage_code,
              harmonized_stages: harmonized,
            }
          end
        end

        stages
      end

      def extract_kw_arg(text, key)
        case text
        when /#{key}:\s*"([^"]*)"/
          $1
        when /#{key}:\s*:(\w+)/
          ":#{$1}"
        when /#{key}:\s*\[([^\]]*)\]/
          $1
        end
      end

      def collect_fixtures
        fixtures = []
        pass_dir = File.join(__dir__, "..", "..", "..", "spec", "fixtures",
                             flavor, "pass")

        return fixtures unless Dir.exist?(pass_dir)

        Dir.glob(File.join(pass_dir, "*.txt")).each do |f|
          lines = File.readlines(f, chomp: true).reject(&:empty?).first(5)
          fixtures.concat(lines)
        end

        fixtures.uniq.first(20)
      rescue StandardError
        fixtures
      end

      def fixture_table(fixtures)
        lines = []
        lines << "| # | Example |"
        lines << "|---|---------|"
        fixtures.each_with_index do |f, i|
          lines << "| #{i + 1} | `#{f}` |"
        end
        lines.join("\n")
      end

      def stage_table(stages)
        lines = []
        lines << "| Abbr | Name | Stage Code | Harmonized Codes |"
        lines << "|------|------|-----------|-----------------|"
        stages.each do |s|
          lines << "| #{s[:abbr]} | #{s[:name]} | #{s[:stage_code]} | #{s[:harmonized_stages]} |"
        end
        lines.join("\n")
      end

      # Cross-flavor comparison table
      def self.generate_cross_flavor_table(flavors)
        lines = []
        lines << "# PubID Identifier Pattern Cross-Flavor Comparison"
        lines << ""
        lines << "| Flavor | ID Types | Typed Stages | URN Support | Normalization |"
        lines << "|--------|----------|-------------|-------------|--------------|"

        flavors.sort.each do |f|
          gen = new(f)
          types = gen.collect_identifier_types.keys.length
          stages = gen.collect_identifier_types.values.sum do |t|
            t[:typed_stages].length
          end
          urn = gen.has_urn_generator? ? "Yes" : "No"
          norm = gen.has_update_codes? ? "Yes" : "No"
          lines << "| #{f.upcase} | #{types} | #{stages} | #{urn} | #{norm} |"
        end

        lines.join("\n")
      end
    end
  end
end
