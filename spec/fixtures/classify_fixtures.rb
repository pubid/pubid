#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

# Fixtures Classification Script
# Reads from identifiers/full/ and classifies into identifiers/pass/ and identifiers/fail/
# Handles three formats: plain, !normalized!, and #errored#
class FixturesClassifier
  FLAVORS = %w[iso iec ieee nist idf cen bsi jis etsi ccsds itu plateau ansi jcgm].freeze

  attr_reader :flavor, :verbose, :fixtures_dir

  def initialize(flavor, verbose: false)
    @flavor = flavor.downcase
    @verbose = verbose
    @fixtures_dir = File.join(__dir__, flavor)
    @stats = {
      total: 0,
      passing: 0,
      failing: 0,
      by_class: Hash.new { |h, k| h[k] = { pass: 0, fail: 0 } }
    }
    validate_flavor!
  end

  def classify
    log "Classifying fixtures for #{flavor.upcase}..."

    unless Dir.exist?(fixtures_dir)
      puts "⚠️  No fixtures directory found for #{flavor.upcase}"
      return false
    end

    # Collect all identifiers from identifiers/full/
    all_identifiers = collect_all_identifiers.uniq

    if all_identifiers.empty?
      puts "⚠️  No identifiers found for #{flavor.upcase}"
      return false
    end

    log "Found #{all_identifiers.size} total identifier entries"

    # Clear existing pass/fail files (but NEVER full/)
    clear_output_files

    # Classify each identifier
    all_identifiers.each do |entry|
      classify_identifier(entry)
    end

    # Generate summary
    generate_summary

    log "✅ Classification complete for #{flavor.upcase}"
    true
  end

  private

  def validate_flavor!
    unless FLAVORS.include?(flavor)
      raise ArgumentError, "Unknown flavor: #{flavor}. Valid: #{FLAVORS.join(', ')}"
    end
  end

  def collect_all_identifiers
    identifiers = []

    # Read from identifiers/full/ ONLY
    full_dir = File.join(fixtures_dir, "identifiers", "full")

    unless Dir.exist?(full_dir)
      log "⚠️  No identifiers/full/ directory found for #{flavor.upcase}"
      return identifiers
    end

    Dir.glob(File.join(full_dir, "*.txt")).each do |file|
      File.readlines(file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")
        identifiers << line
      end
    end

    identifiers
  end

  def clear_output_files
    # Clear pass/ and fail/ (but NEVER full/)
    pass_dir = File.join(fixtures_dir, "identifiers", "pass")
    fail_dir = File.join(fixtures_dir, "identifiers", "fail")

    FileUtils.rm_rf(pass_dir)
    FileUtils.rm_rf(fail_dir)
    FileUtils.mkdir_p(pass_dir)
    FileUtils.mkdir_p(fail_dir)
  end

  def classify_identifier(entry)
    @stats[:total] += 1

    case entry
    when /^!(.+)!(.+)$/  # Normalized format
      classify_normalized($1, $2)
    when /^#(.+)# (.+)$/  # Errored format
      classify_errored($1, $2)
    else  # Plain identifier
      classify_plain(entry)
    end
  end

  def classify_plain(id_str)
    begin
      parsed = parse_identifier(id_str)
      rendered = parsed.to_s

      if rendered == id_str
        # Perfect round-trip - write as plain
        @stats[:passing] += 1
        class_name = detect_class_name(parsed, id_str)
        @stats[:by_class][class_name][:pass] += 1
        append_to_file("pass", class_name, id_str)
      else
        # Successful parse but different rendering - write as normalized to PASS
        @stats[:passing] += 1
        class_name = detect_class_name(parsed, id_str)
        @stats[:by_class][class_name][:pass] += 1
        append_to_file("pass", class_name, "!#{id_str}!#{rendered}")
      end
    rescue StandardError => e
      # Parse failed - write as errored to FAIL
      @stats[:failing] += 1
      class_name = detect_class_from_string(id_str)
      @stats[:by_class][class_name][:fail] += 1
      append_to_file("fail", class_name, "##{id_str}# #{e.class}: #{e.message.inspect}")
    end
  end

  def classify_normalized(original, expected)
    begin
      parsed = parse_identifier(original)
      actual_rendered = parsed.to_s

      if actual_rendered == expected
        # Success! Normalization works as expected
        @stats[:passing] += 1
        class_name = detect_class_name(parsed, original)
        @stats[:by_class][class_name][:pass] += 1
        append_to_file("pass", class_name, "!#{original}!#{expected}")
      else
        # Mismatch - parser renders differently than expected
        @stats[:failing] += 1
        class_name = detect_class_name(parsed, original)
        @stats[:by_class][class_name][:fail] += 1
        error_msg = "Expected: #{expected}, Got: #{actual_rendered}"
        append_to_file("fail", class_name, "##{original}# Mismatch: #{error_msg}")
      end
    rescue StandardError => e
      # Parse failed
      @stats[:failing] += 1
      class_name = detect_class_from_string(original)
      @stats[:by_class][class_name][:fail] += 1
      append_to_file("fail", class_name, "##{original}# #{e.class}: #{e.message.inspect}")
    end
  end

  def classify_errored(original, error_msg)
    # Re-validate: maybe it parses now after fixes?
    begin
      parsed = parse_identifier(original)
      rendered = parsed.to_s
      # It parses now! Move to pass
      @stats[:passing] += 1
      class_name = detect_class_name(parsed, original)
      @stats[:by_class][class_name][:pass] += 1
      append_to_file("pass", class_name, "!#{original}!#{rendered}")
    rescue StandardError => e
      # Still fails, keep in fail with updated error
      @stats[:failing] += 1
      class_name = detect_class_from_string(original)
      @stats[:by_class][class_name][:fail] += 1
      append_to_file("fail", class_name, "##{original}# #{e.class}: #{e.message.inspect}")
    end
  end

  def parse_identifier(id_str)
    case flavor
    when "iso" then PubidNew::Iso.parse(id_str)
    when "iec" then PubidNew::Iec.parse(id_str)
    when "ieee" then PubidNew::Ieee.parse(id_str)
    when "nist" then PubidNew::Nist.parse(id_str)
    when "jcgm" then PubidNew::Jcgm.parse(id_str)
    when "jis" then PubidNew::Jis.parse(id_str)
    when "etsi" then PubidNew::Etsi.parse(id_str)
    when "ccsds" then PubidNew::Ccsds.parse(id_str)
    when "itu" then PubidNew::Itu.parse(id_str)
    when "plateau" then PubidNew::Plateau.parse(id_str)
    when "ansi" then PubidNew::Ansi.parse(id_str)
    when "cen" then PubidNew::Cen.parse(id_str)
    when "bsi" then PubidNew::Bsi.parse(id_str)
    when "idf" then PubidNew::Idf.parse(id_str)
    else
      raise "Unknown flavor: #{flavor}"
    end
  end

  def detect_class_name(parsed, original_str)
    class_name = parsed.class.name.split("::").last
    underscore(class_name)
  rescue StandardError
    detect_class_from_string(original_str)
  end

  def detect_class_from_string(id_str)
    case flavor
    when "iso" then detect_iso_class(id_str)
    when "iec" then detect_iec_class(id_str)
    when "ieee" then detect_ieee_class(id_str)
    when "nist" then detect_nist_class(id_str)
    when "jcgm" then detect_jcgm_class(id_str)
    else "unknown"
    end
  end

  def detect_iso_class(id_str)
    return "nsb_format" if id_str =~ /FprISO|PrISO/
    return "cyrillic" if id_str =~ /[А-Яа-яЁё]/
    return "guide" if id_str =~ /Guide/i
    return "directives" if id_str =~ /DIR/
    return "amendment" if id_str =~ /\/Amd|\/AMD|\/FDAM|\/PDAM|\/DAM/
    return "corrigendum" if id_str =~ /\/Cor|\/COR|\/FDCOR|\/DCOR/
    return "technical_report" if id_str =~ /\bTR\b/
    return "technical_specification" if id_str =~ /\bTS\b/
    return "pas" if id_str =~ /\bPAS\b/
    return "international_workshop_agreement" if id_str =~ /\bIWA\b/
    return "addendum" if id_str =~ /\/Add/
    "international_standard"
  end

  def detect_iec_class(id_str)
    return "technical_report" if id_str =~ /\bTR\b/
    return "technical_specification" if id_str =~ /\bTS\b/
    return "guide" if id_str =~ /GUIDE/i
    return "pas" if id_str =~ /\bPAS\b/
    return "srd" if id_str =~ /\bSRD\b/
    return "amendment" if id_str =~ /\/AMD/
    return "corrigendum" if id_str =~ /\/COR/
    return "interpretation_sheet" if id_str =~ /\/ISH/
    return "vap_identifier" if id_str =~ /\bVAP\b/
    return "consolidated_identifier" if id_str =~ /\+AMD|\+COR/
    "international_standard"
  end

  def detect_ieee_class(id_str)
    "standard"
  end

  def detect_nist_class(id_str)
    return "fips" if id_str =~ /\bFIPS\b/
    return "sp" if id_str =~ /\bSP\b/
    return "nist_ir" if id_str =~ /\bNISTIR\b/
    "unknown"
  end

  def detect_jcgm_class(id_str)
    return "guide" if id_str =~ /^JCGM \d+/
    "unknown"
  end

  def append_to_file(status, class_name, content)
    filename = File.join(fixtures_dir, "identifiers", status, "#{class_name}.txt")

    unless File.exist?(filename)
      File.open(filename, "w") do |f|
        f.puts "# #{flavor.upcase} #{class_name.tr('_', ' ').split.map(&:capitalize).join(' ')} - #{status.capitalize}"
        f.puts "# Auto-generated by classify_fixtures.rb"
        f.puts
      end
    end

    File.open(filename, "a") do |f|
      f.puts content
    end
  end

  def generate_summary
    filename = File.join(fixtures_dir, "SUMMARY.txt")

    File.open(filename, "w") do |f|
      f.puts "Flavor: #{flavor.upcase}"
      f.puts "Classified: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts "=" * 70
      f.puts
      f.puts "OVERALL STATISTICS"
      f.puts "-" * 70
      f.puts "Total: #{@stats[:total]}"
      f.puts "Pass: #{@stats[:passing]} (#{percentage(@stats[:passing], @stats[:total])}%)"
      f.puts "Fail: #{@stats[:failing]} (#{percentage(@stats[:failing], @stats[:total])}%)"
      f.puts
      f.puts "BY CLASS"
      f.puts "-" * 70

      @stats[:by_class].sort_by { |k, _| k }.each do |class_name, counts|
        total = counts[:pass] + counts[:fail]
        pass_pct = percentage(counts[:pass], total)
        f.puts "#{class_name.ljust(40)} Pass: #{counts[:pass]}/#{total} (#{pass_pct}%)"
      end
    end

    puts
    puts "=" * 70
    puts "CLASSIFICATION COMPLETE: #{flavor.upcase}"
    puts "=" * 70
    puts "Total: #{@stats[:total]}"
    puts "Pass:  #{@stats[:passing]} (#{percentage(@stats[:passing], @stats[:total])}%)"
    puts "Fail:  #{@stats[:failing]} (#{percentage(@stats[:failing], @stats[:total])}%)"
    puts "=" * 70
  end

  def percentage(part, whole)
    return 0 if whole.zero?
    ((part.to_f / whole) * 100).round(2)
  end

  def underscore(camel_cased_word)
    camel_cased_word.to_s.gsub("::", "/")
                    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                    .tr("-", "_")
                    .downcase
  end

  def log(message)
    puts message if verbose
  end
end