#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

class FixturesMigrator
  FLAVORS = %w[iso iec ieee nist idf cen bsi jis etsi ccsds itu plateau
               ansi].freeze

  def initialize(flavor, verbose: false)
    @flavor = flavor.downcase
    @verbose = verbose
    @fixtures_dir = File.join(__dir__, flavor)
    validate_flavor!
  end

  def migrate
    log "=" * 60
    log "Migrating #{@flavor.upcase} to new structure..."
    log "=" * 60

    # 1. Create new directory structure
    create_new_structure

    # 2. Collect all identifiers from pass and fail
    all_identifiers = collect_all_identifiers

    if all_identifiers.empty?
      log "⚠️  No identifiers found for #{@flavor.upcase}"
      return false
    end

    # 3. Group by class and write to full/
    write_full_files(all_identifiers)

    # 4. Backup old structure
    backup_old_structure

    # 5. Remove old pass/fail directories
    remove_old_structure

    log "✅ Migration complete for #{@flavor.upcase}"
    log ""
    true
  end

  private

  def create_new_structure
    full_dir = File.join(@fixtures_dir, "identifiers", "full")
    FileUtils.mkdir_p(full_dir)
    log "Created: #{full_dir}"
  end

  def collect_all_identifiers
    identifiers = []

    # From pass/ - keep format (plain or !original!expected)
    pass_dir = File.join(@fixtures_dir, "pass")
    if Dir.exist?(pass_dir)
      log "Collecting from pass/..."
      Dir.glob(File.join(pass_dir, "*.txt")).each do |file|
        class_name = File.basename(file, ".txt")
        count = 0
        File.readlines(file).each do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")

          identifiers << { class: class_name, content: line }
          count += 1
        end
        log "  - #{class_name}.txt: #{count} identifiers"
      end
    end

    # From fail/ - convert to errored format
    fail_dir = File.join(@fixtures_dir, "fail")
    if Dir.exist?(fail_dir)
      log "Collecting from fail/..."
      Dir.glob(File.join(fail_dir, "*.txt")).each do |file|
        class_name = File.basename(file, ".txt")
        count = 0
        File.readlines(file).each do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")

          # If already in error format, keep it
          if line.start_with?("#") && line.include?("#", 1)
            identifiers << { class: class_name, content: line }
          else
            # Convert to errored format
            identifiers << { class: class_name,
                             content: "##{line}# ParseError: \"migrated from fail\"" }
          end
          count += 1
        end
        log "  - #{class_name}.txt: #{count} identifiers"
      end
    end

    log "Total identifiers collected: #{identifiers.size}"
    identifiers.uniq { |id| "#{id[:class]}|#{id[:content]}" }
  end

  def write_full_files(identifiers)
    # Group by class
    by_class = identifiers.group_by { |id| id[:class] }

    log "Writing to full/ directory..."
    by_class.each do |class_name, ids|
      filename = File.join(@fixtures_dir, "identifiers", "full",
                           "#{class_name}.txt")

      # Sort and get unique contents
      unique_contents = ids.map { |id| id[:content] }.uniq.sort

      File.open(filename, "w") do |f|
        f.puts "# #{@flavor.upcase} #{class_name.tr('_',
                                                    ' ').split.map(&:capitalize).join(' ')} - Full"
        f.puts "# Source of truth for all #{class_name.tr('_',
                                                          ' ')} identifiers"
        f.puts "# Auto-generated during migration"
        f.puts

        unique_contents.each do |content|
          f.puts content
        end
      end

      log "  - #{class_name}.txt: #{unique_contents.size} unique identifiers"
    end
  end

  def backup_old_structure
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")

    pass_dir = File.join(@fixtures_dir, "pass")
    if Dir.exist?(pass_dir)
      backup_dir_pass = File.join(@fixtures_dir, "pass_backup_#{timestamp}")
      FileUtils.cp_r(pass_dir, backup_dir_pass)
      log "Backed up pass/ to #{File.basename(backup_dir_pass)}"
    end

    fail_dir = File.join(@fixtures_dir, "fail")
    if Dir.exist?(fail_dir)
      backup_dir_fail = File.join(@fixtures_dir, "fail_backup_#{timestamp}")
      FileUtils.cp_r(fail_dir, backup_dir_fail)
      log "Backed up fail/ to #{File.basename(backup_dir_fail)}"
    end
  end

  def remove_old_structure
    pass_dir = File.join(@fixtures_dir, "pass")
    fail_dir = File.join(@fixtures_dir, "fail")

    if Dir.exist?(pass_dir)
      FileUtils.rm_rf(pass_dir)
      log "Removed old pass/ directory"
    end

    if Dir.exist?(fail_dir)
      FileUtils.rm_rf(fail_dir)
      log "Removed old fail/ directory"
    end
  end

  def validate_flavor!
    unless FLAVORS.include?(@flavor)
      raise ArgumentError,
            "Unknown flavor: #{@flavor}. Valid: #{FLAVORS.join(', ')}"
    end
  end

  def log(message)
     if @verbose
  end
end

# CLI interface
if __FILE__ == $PROGRAM_NAME
  flavor = ARGV[0]&.downcase

  if flavor.nil?
    
    
    
    
    exit 1
  end

  migrator = FixturesMigrator.new(flavor, verbose: true)
  success = migrator.migrate
  exit(success ? 0 : 1)
end
