#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates docs/legacy-update-codes-reference.md from data/{flavor}/update_codes.yaml files

require "yaml"

DATA_DIR = "data"
OUTPUT = "docs/legacy-update-codes-reference.md"

FLAVORS = {
  "iso" => "ISO",
  "iec" => "IEC",
  "ieee" => "IEEE",
  "nist" => "NIST",
  "ccsds" => "CCSDS",
  "plateau" => "PLATEAU",
}.freeze

def read_yaml_file(file)
  File.read("#{DATA_DIR}/#{file}/update_codes.yaml")
rescue Errno::ENOENT
  nil
end

def parse_yaml_content(content)
  return [] unless content

  entries = []
  content.lines.each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    if line.include?(":")
      # Parse "key: value" or "key: -> value" (regex)
      parts = line.split(": ", 2)
      if parts.length == 2
        key = parts[0].strip
        value = parts[1].strip
        entries << { key: key, value: value, regex: false }
      elsif line =~ %r{^/(.*)/:\s*(.+)$} # Regex pattern: /pattern/: value
        entries << { key: line, value: $2.strip, regex: true }
      end
    end
  end
  entries
end

def render_entries(entries)
  lines = entries.map do |entry|
    "`#{entry[:key]}` → `#{entry[:value]}`"
  end
  lines.join("\n")
end

# Generate markdown
md = <<~HEADER
  # Legacy Update Codes Reference

  This document contains the pre-parsing normalization mappings from `update_codes.yaml` files
  in the `data/{flavor}/` directory. These mappings fix malformed but commonly-seen identifiers
  before they reach the parser.

  **Purpose**: When implementing identifier parsing, if a malformed identifier is encountered
  that should be normalized, use these mappings as reference.

  **Regenerate**: Run `ruby docs/generate_legacy_update_codes.rb` to update this file.

  ---

HEADER

FLAVORS.each do |dir, name|
  content = read_yaml_file(dir)
  if content.nil? || content.empty?
    puts "Warning: data/#{dir}/update_codes.yaml not found"
    next
  end

  entries = parse_yaml_content(content)

  md += <<~SECTION
    ## #{name} (data/#{dir}/update_codes.yaml)

    ```yaml
    #{content.strip}
    ```

    Parsed entries (#{entries.length}):
    #{render_entries(entries)}

    ---

  SECTION
end

md += <<~FOOTER
  ## Notes

  - Entries with regex patterns (e.g., `/^NBS CIRC sup$/`) use YAML regex syntax
  - Entries with colons inside quotes (e.g., `"IEC 60309-3:1994/FRAG1:"`) preserve trailing colons
  - Some entries map legacy AIEE numbering to IEEE format
  - IEEE entries handle "Unapproved Draft Std" variations and date formatting

  ## Regeneration

  To regenerate this file, run:

  ```bash
  ruby docs/generate_legacy_update_codes.rb
  ```

  This fetches the latest `update_codes.yaml` files from `data/` and regenerates
  the documentation.
FOOTER

# Write output
File.write(OUTPUT, md)
puts "Generated #{OUTPUT}"
