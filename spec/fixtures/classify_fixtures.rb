#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "bundler/setup"
require_relative "../../lib/pubid"

# Fixtures Classification Script
# Reads from identifiers/full/ and classifies into identifiers/pass/ and identifiers/fail/
# Handles three formats: plain, !normalized!, and #errored#
class FixturesClassifier
  attr_reader :flavor, :verbose, :fixtures_dir

  def initialize(flavor, verbose: false)
    @flavor = flavor.downcase
    @verbose = verbose
    @fixtures_dir = File.join(__dir__, flavor)
    @stats = {
      total: 0,
      passing: 0,
      failing: 0,
      by_class: Hash.new { |h, k| h[k] = { pass: 0, fail: 0 } },
    }
    validate_flavor!
  end

  def classify
    log "Classifying fixtures for #{flavor.upcase}..."

    unless Dir.exist?(fixtures_dir)
      
      return false
    end

    # Collect all identifiers from identifiers/full/
    all_identifiers = collect_all_identifiers.uniq

    if all_identifiers.empty?
      
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
    unless Pubid::Registry.registered?(flavor)
      raise ArgumentError,
            "Unknown flavor: #{flavor}. Valid: #{Pubid::Registry.flavor_names.join(', ')}"
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
    when /^!(.+)!(.+)$/ # Normalized format
      classify_normalized($1, $2)
    when /^#(.+)# (.+)$/ # Errored format
      classify_errored($1, $2)
    else # Plain identifier
      classify_plain(entry)
    end
  end

  def classify_plain(id_str)
    parsed = parse_identifier(id_str)
    rendered = parsed.to_s

    @stats[:passing] += 1
    class_name = detect_class_name(parsed, id_str)
    @stats[:by_class][class_name][:pass] += 1
    if rendered == id_str
      # Perfect round-trip - write as plain
      append_to_file("pass", class_name, id_str)
    else
      # Successful parse but different rendering - write as normalized to PASS
      append_to_file("pass", class_name, "!#{id_str}!#{rendered}")
    end
  rescue StandardError => e
    # Parse failed - write as errored to FAIL
    @stats[:failing] += 1
    class_name = detect_class_from_string(id_str)
    @stats[:by_class][class_name][:fail] += 1
    append_to_file("fail", class_name,
                   "##{id_str}# #{e.class}: #{e.message.inspect}")
  end

  def classify_normalized(original, _expected)
    parsed = parse_identifier(original)
    actual_rendered = parsed.to_s

    # SUCCESS: It parses! Use actual rendered output, not old expectation
    @stats[:passing] += 1
    class_name = detect_class_name(parsed, original)
    @stats[:by_class][class_name][:pass] += 1

    # Write with ACTUAL rendered output (may differ from old expectation)
    if actual_rendered == original
      # Perfect round-trip now
      append_to_file("pass", class_name, original)
    else
      # Still normalized, but use actual rendering
      append_to_file("pass", class_name, "!#{original}!#{actual_rendered}")
    end
  rescue StandardError => e
    # FAIL: Parse error
    @stats[:failing] += 1
    class_name = detect_class_from_string(original)
    @stats[:by_class][class_name][:fail] += 1
    append_to_file("fail", class_name,
                   "##{original}# #{e.class}: #{e.message.inspect}")
  end

  def classify_errored(original, _error_msg)
    # Re-validate: maybe it parses now after fixes?

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
    append_to_file("fail", class_name,
                   "##{original}# #{e.class}: #{e.message.inspect}")
  end

  def parse_identifier(id_str)
    flavor_module = Pubid::Registry.get(flavor)
    if flavor_module.respond_to?(:parse)
      flavor_module.parse(id_str)
    else
      raise "Unknown or unsupported flavor: #{flavor}"
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
    when "astm" then detect_astm_class(id_str)
    when "asme" then detect_asme_class(id_str)
    when "api" then detect_api_class(id_str)
    when "oiml" then detect_oiml_class(id_str)
    when "idf" then detect_idf_class(id_str)
    when "csa" then detect_csa_class(id_str)
    when "ashrae" then detect_ashrae_class(id_str)
    else "unknown"
    end
  end

  def detect_iso_class(id_str)
    return "nsb_format" if /FprISO|PrISO/.match?(id_str)
    return "cyrillic" if /[А-Яа-яЁё]/.match?(id_str)
    return "guide" if /Guide/i.match?(id_str)
    return "directives" if id_str.include?("DIR")
    return "amendment" if /\/Amd|\/AMD|\/FDAM|\/PDAM|\/DAM/.match?(id_str)
    return "corrigendum" if /\/Cor|\/COR|\/FDCOR|\/DCOR/.match?(id_str)
    return "technical_report" if /\bTR\b/.match?(id_str)
    return "technical_specification" if /\bTS\b/.match?(id_str)
    return "pas" if /\bPAS\b/.match?(id_str)
    return "international_workshop_agreement" if /\bIWA\b/.match?(id_str)
    return "addendum" if id_str.include?("/Add")

    "international_standard"
  end

  def detect_iec_class(id_str)
    return "technical_report" if /\bTR\b/.match?(id_str)
    return "technical_specification" if /\bTS\b/.match?(id_str)
    return "guide" if /GUIDE/i.match?(id_str)
    return "pas" if /\bPAS\b/.match?(id_str)
    return "srd" if /\bSRD\b/.match?(id_str)
    return "amendment" if id_str.include?("/AMD")
    return "corrigendum" if id_str.include?("/COR")
    return "interpretation_sheet" if id_str.include?("/ISH")
    return "vap_identifier" if /\bVAP\b/.match?(id_str)
    return "consolidated_identifier" if /\+AMD|\+COR/.match?(id_str)

    "international_standard"
  end

  def detect_ieee_class(id_str)
    return "nesc/standard" if /\bC2-/.match?(id_str)
    return "nesc/handbook" if /NESC.*Handbook/i.match?(id_str)
    return "standard" if /\bIEEE Std\b/.match?(id_str)
    return "base" if /\bIEEE\b/.match?(id_str)

    "standard" # Default fallback for IEEE
  end

  def detect_nist_class(id_str)
    return "fips" if /\bFIPS\b/.match?(id_str)
    return "sp" if /\bSP\b/.match?(id_str)
    return "nist_ir" if /\bNISTIR\b/.match?(id_str)

    "unknown"
  end

  def detect_jcgm_class(id_str)
    return "guide" if /^JCGM \d+/.match?(id_str)

    "unknown"
  end

  def detect_astm_class(id_str)
    return "research_report" if /\bRR:/.match?(id_str)
    return "manual" if /\bMNL/.match?(id_str)
    return "monograph" if /\bMONO/.match?(id_str)
    return "data_series" if /\bDS\d/.match?(id_str)
    return "work_in_progress" if /\bWK/.match?(id_str)
    return "adjunct" if /\bADJ/.match?(id_str)
    return "technical_report" if /\bTR\d|ISO\/ASTMTR/.match?(id_str)

    "standard"
  end

  def detect_asme_class(id_str)
    return "joint_published" if /CSA\/ASME|API\/ASME|ISO\/ASME/.match?(id_str)

    "standard"
  end

  def detect_api_class(id_str)
    return "bull" if /\bBULL\b/.match?(id_str)
    return "mpms" if /\bMPMS\b/.match?(id_str)
    return "rp" if /\bRP\b/.match?(id_str)
    return "spec" if /\bSPEC\b/.match?(id_str)
    return "std" if /\bSTD\b/.match?(id_str)
    return "tr" if /\bTR\b/.match?(id_str)

    "publication"
  end

  def detect_oiml_class(id_str)
    return "basic_publication" if /\bB \d/.match?(id_str)
    return "document" if /\bD \d/.match?(id_str)
    return "expert_report" if /\bE \d/.match?(id_str)
    return "guide" if /\bG \d/.match?(id_str)
    return "recommendation" if /\bR \d/.match?(id_str)
    return "seminar_report" if /\bS \d/.match?(id_str)
    return "vocabulary" if /\bV \d|VIML/.match?(id_str)
    return "amendment" if id_str.include?("Amendment")
    return "annex" if id_str.include?("Annex")

    "unknown"
  end

  def detect_idf_class(id_str)
    return "international_standard" if /^IDF \d/.match?(id_str)
    return "reviewed_method" if id_str.include?("(RM)")
    return "amendment" if id_str.include?("Amendment")
    return "corrigendum" if id_str.include?("Corrigendum")

    "unknown"
  end

  def detect_csa_class(id_str)
    return "series" if id_str.include?("SERIES")
    return "bundled" if id_str.include?("+")
    return "combined" if id_str.include?("/")
    return "package" if id_str.include?("PACKAGE")
    return "canadian_adopted" if /^CAN\//.match?(id_str)
    return "csa_adopted" if /CSA ISO|CSA IEC|CSA CISPR/.match?(id_str)

    "standard"
  end

  def detect_ashrae_class(id_str)
    return "guideline" if /\bGuideline\b/.match?(id_str)
    return "addendum" if /\bAddendum\b/.match?(id_str)
    return "interpretation" if /\bInterpretations\b/.match?(id_str)
    return "errata" if /\bErrata\b/.match?(id_str)

    "standard"
  end

  def append_to_file(status, class_name, content)
    filename = File.join(fixtures_dir, "identifiers", status,
                         "#{class_name}.txt")

    # Create parent directories if needed
    parent_dir = File.dirname(filename)
    FileUtils.mkdir_p(parent_dir)

    unless File.exist?(filename)
      File.open(filename, "w") do |f|
        f.puts "# #{flavor.upcase} #{class_name.tr('_',
                                                   ' ').split.map(&:capitalize).join(' ')} - #{status.capitalize}"
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
      f.puts "Pass: #{@stats[:passing]} (#{percentage(@stats[:passing],
                                                      @stats[:total])}%)"
      f.puts "Fail: #{@stats[:failing]} (#{percentage(@stats[:failing],
                                                      @stats[:total])}%)"
      f.puts
      f.puts "BY CLASS"
      f.puts "-" * 70

      @stats[:by_class].sort_by { |k, _| k }.each do |class_name, counts|
        total = counts[:pass] + counts[:fail]
        pass_pct = percentage(counts[:pass], total)
        f.puts "#{class_name.ljust(40)} Pass: #{counts[:pass]}/#{total} (#{pass_pct}%)"
      end
    end

    
    
    
    
    
    
    
    
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
    puts message if @verbose
  end
end
