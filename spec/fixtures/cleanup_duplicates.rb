#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "set"

# Cleanup script to remove duplicates between old fixtures and new pass/fail structure
class FixturesCleaner
  FLAVORS = %w[iso iec ieee nist].freeze

  def initialize(verbose: false)
    @verbose = verbose
    @stats = {
      files_processed: 0,
      files_deleted: 0,
      lines_removed: 0,
      identifiers_in_pass_fail: 0,
    }
  end

  def clean_all
    puts "Cleaning up duplicate fixtures..."
    puts "=" * 70

    FLAVORS.each do |flavor|
      clean_flavor(flavor)
    end

    print_summary
  end

  private

  def clean_flavor(flavor)
    flavor_dir = File.join(__dir__, flavor)

    unless Dir.exist?(flavor_dir)
      log "⚠️  Flavor directory not found: #{flavor_dir}"
      return
    end

    log "\nProcessing #{flavor.upcase}..."

    # Load all identifiers from pass/ and fail/ directories
    organized_identifiers = load_organized_identifiers(flavor_dir)
    @stats[:identifiers_in_pass_fail] += organized_identifiers.size

    log "  Found #{organized_identifiers.size} identifiers in pass/fail directories"

    # Process each .txt file in flavor root
    old_fixture_files = Dir.glob(File.join(flavor_dir, "*.txt"))
      .reject { |f| File.basename(f) == "SUMMARY.txt" }

    log "  Found #{old_fixture_files.size} old fixture files to check"

    old_fixture_files.each do |file|
      process_file(file, organized_identifiers)
    end
  end

  def load_organized_identifiers(flavor_dir)
    identifiers = Set.new

    # Load from pass/ directory
    pass_files = Dir.glob(File.join(flavor_dir, "pass", "*.txt"))
    pass_files.each do |file|
      File.readlines(file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        identifiers << line
      end
    end

    # Load from fail/ directory
    fail_files = Dir.glob(File.join(flavor_dir, "fail", "*.txt"))
    fail_files.each do |file|
      File.readlines(file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        identifiers << line
      end
    end

    identifiers
  end

  def process_file(file, organized_identifiers)
    filename = File.basename(file)
    @stats[:files_processed] += 1

    log "    Checking #{filename}..."

    # Read all lines from the file
    lines = File.readlines(file)
    lines.size

    # Filter out duplicates
    kept_lines = []
    removed_count = 0

    lines.each do |line|
      stripped = line.strip

      # Keep comments and empty lines
      if stripped.empty? || stripped.start_with?("#")
        kept_lines << line
        next
      end

      # Check if this identifier exists in organized fixtures
      if organized_identifiers.include?(stripped)
        removed_count += 1
        @stats[:lines_removed] += 1
      else
        kept_lines << line
      end
    end

    if removed_count > 0
      # Check if file is now empty (only comments/whitespace)
      non_comment_lines = kept_lines.reject do |l|
        l.strip.empty? || l.strip.start_with?("#")
      end

      if non_comment_lines.empty?
        # Delete the file
        File.delete(file)
        @stats[:files_deleted] += 1
        log "      ✓ Deleted #{filename} (all #{removed_count} identifiers moved to pass/fail)"
      else
        # Rewrite the file
        File.write(file, kept_lines.join)
        log "      ✓ Removed #{removed_count} duplicates from #{filename} (#{non_comment_lines.size} remaining)"
      end
    else
      log "      - No duplicates found in #{filename}"
    end
  end

  def print_summary
    puts
    puts "=" * 70
    puts "CLEANUP COMPLETE"
    puts "=" * 70
    puts "Files processed:           #{@stats[:files_processed]}"
    puts "Files deleted:             #{@stats[:files_deleted]}"
    puts "Duplicate lines removed:   #{@stats[:lines_removed]}"
    puts "Total in pass/fail:        #{@stats[:identifiers_in_pass_fail]}"
    puts "=" * 70
  end

  def log(message)
    puts message if @verbose
  end
end

# Run cleanup
if __FILE__ == $PROGRAM_NAME
  verbose = ARGV.include?("--verbose") || ARGV.include?("-v")

  unless ARGV.include?("--confirm")
    puts "This will remove duplicate identifiers from old fixture files."
    puts "Files will be deleted if all identifiers have been moved to pass/fail."
    puts
    puts "Run with --confirm to proceed:"
    puts "  ruby cleanup_duplicates.rb --confirm [--verbose]"
    exit 1
  end

  cleaner = FixturesCleaner.new(verbose: verbose)
  cleaner.clean_all
end
