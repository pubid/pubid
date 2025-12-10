# Session 103 Continuation Plan: Fixtures Classification Redesign Implementation

**Created:** 2025-12-10 (Post-Session 102)
**Status:** Ready to implement
**Timeline:** COMPRESSED - Complete in 3 sessions (103-105)

---

## Context

Session 102 completed final validation and archival. User requested a complete redesign of the fixtures classification system with:

1. **New structure**: `identifiers/{full,pass,fail}` instead of `{pass,fail}`
2. **Three syntaxes**: plain, normalized `!original!normalized`, errored `#original# error`
3. **Non-destructive**: Read from `full/`, generate `pass/fail/`

See [`.kilocode/rules/memory-bank/session-102-fixtures-redesign-plan.md`](.kilocode/rules/memory-bank/session-102-fixtures-redesign-plan.md:1) for full design.

---

## SESSION 103: Migration + New Script (120 minutes)

### Objectives
1. Create migration script to move existing data to new structure
2. Rewrite classify script with new three-syntax system
3. Test on IDF (smallest flavor)
4. Validate structure and results

### Part A: Create Migration Script (40 min)

**Create:** `spec/fixtures/migrate_to_new_structure.rb`

**Key Requirements:**
- Migrate one flavor at a time
- Create `identifiers/full/` structure
- Gather from existing `pass/` (keep formats)
- Gather from existing `fail/` (convert to errored format)
- Group by class
- Write to `full/{class}.txt`
- Backup old structure to `pass_backup/` and `fail_backup/`

**Expected Structure After Migration:**
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

class FixturesMigrator
  FLAVORS = %w[iso iec ieee nist idf cen bsi jis etsi ccsds itu plateau ansi]
  
  def initialize(flavor, verbose: false)
    @flavor = flavor.downcase
    @verbose = verbose
    @fixtures_dir = File.join(__dir__, flavor)
    validate_flavor!
  end
  
  def migrate
    log "Migrating #{@flavor.upcase} to new structure..."
    
    # 1. Create new directory structure  
    create_new_structure
    
    # 2. Collect all identifiers from pass and fail
    all_identifiers = collect_all_identifiers
    
    # 3. Group by class and write to full/
    write_full_files(all_identifiers)
    
    # 4. Backup old structure
    backup_old_structure
    
    # 5. Remove old pass/fail directories
    remove_old_structure
    
    log "✅ Migration complete for #{@flavor.upcase}"
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
      Dir.glob(File.join(pass_dir, "*.txt")).each do |file|
        class_name = File.basename(file, ".txt")
        File.readlines(file).each do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")
          identifiers << { class: class_name, content: line }
        end
      end
    end
    
    # From fail/ - convert to errored format
    fail_dir = File.join(@fixtures_dir, "fail")
    if Dir.exist?(fail_dir)
      Dir.glob(File.join(fail_dir, "*.txt")).each do |file|
        class_name = File.basename(file, ".txt")
        File.readlines(file).each do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")
          
          # If already in error format, keep it
          if line.start_with?("#") && line.include?("#", 1)
            identifiers << { class: class_name, content: line }
          else
            # Convert to errored format
            identifiers << { class: class_name, content: "##{line}# ParseError: \"migrated from fail\"" }
          end
        end
      end
    end
    
    identifiers.uniq { |id| id[:content] }
  end
  
  def write_full_files(identifiers)
    # Group by class
    by_class = identifiers.group_by { |id| id[:class] }
    
    by_class.each do |class_name, ids|
      filename = File.join(@fixtures_dir, "identifiers", "full", "#{class_name}.txt")
      
      File.open(filename, "w") do |f|
        f.puts "# #{@flavor.upcase} #{class_name.tr('_', ' ').split.map(&:capitalize).join(' ')} - Full"
        f.puts "# Source of truth for all #{class_name.tr('_', ' ')} identifiers"
        f.puts "# Auto-generated during migration"
        f.puts
        
        # Sort and write unique identifiers
        ids.map { |id| id[:content] }.uniq.sort.each do |content|
          f.puts content
        end
      end
      
      log "Wrote #{ids.size} identifiers to #{class_name}.txt"
    end
  end
  
  def backup_old_structure
    backup_dir_pass = File.join(@fixtures_dir, "pass_backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
    backup_dir_fail = File.join(@fixtures_dir, "fail_backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
    
    if Dir.exist?(File.join(@fixtures_dir, "pass"))
      FileUtils.cp_r(File.join(@fixtures_dir, "pass"), backup_dir_pass)
      log "Backed up pass/ to #{backup_dir_pass}"
    end
    
    if Dir.exist?(File.join(@fixtures_dir, "fail"))
      FileUtils.cp_r(File.join(@fixtures_dir, "fail"), backup_dir_fail)
      log "Backed up fail/ to #{backup_dir_fail}"
    end
  end
  
  def remove_old_structure
    FileUtils.rm_rf(File.join(@fixtures_dir, "pass"))
    FileUtils.rm_rf(File.join(@fixtures_dir, "fail"))
    log "Removed old pass/ and fail/ directories"
  end
  
  def validate_flavor!
    unless FLAVORS.include?(@flavor)
      raise ArgumentError, "Unknown flavor: #{@flavor}. Valid: #{FLAVORS.join(', ')}"
    end
  end
  
  def log(message)
    puts message if @verbose
  end
end

# CLI interface
if __FILE__ == $0
  flavor = ARGV[0]&.downcase
  
  if flavor.nil?
    puts "Usage: ruby migrate_to_new_structure.rb <flavor>"
    puts "Example: ruby migrate_to_new_structure.rb idf"
    exit 1
  end
  
  migrator = FixturesMigrator.new(flavor, verbose: true)
  success = migrator.migrate
  exit(success ? 0 : 1)
end
```

### Part B: Rewrite Classify Script (50 min)

**Rewrite:** [`spec/fixtures/classify_fixtures.rb`](../../spec/fixtures/classify_fixtures.rb:1)

**Key Changes:**
1. Read from `identifiers/full/` ONLY (never from pass/fail)
2. Never delete `full/` directory
3. Clear and regenerate `pass/` and `fail/` directories
4. Handle three input formats:
   - Plain: `ISO 8601:2019`
   - Normalized: `!ISO  8601: 2019!ISO 8601:2019`
   - Errored: `#ISO INVALID# ParseError: "message"`
5. Output to correct location based on parse success

**Three Classification Handlers:**

```ruby
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
      # Successful parse but different rendering - write as normalized
      @stats[:passing] += 1
      class_name = detect_class_name(parsed, id_str)
      @stats[:by_class][class_name][:pass] += 1
      append_to_file("pass", class_name, "!#{id_str}!#{rendered}")
    end
  rescue StandardError => e
    # Parse failed - write as errored
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
```

**Main Changes to collect_all_identifiers:**

```ruby
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
  
  identifiers.uniq
end
```

**Main Changes to clear_output_files:**

```ruby
def clear_output_files
  # Clear pass/ and fail/ (but NEVER full/)
  pass_dir = File.join(fixtures_dir, "identifiers", "pass")
  fail_dir = File.join(fixtures_dir, "identifiers", "fail")
  
  FileUtils.rm_rf(pass_dir)
  FileUtils.rm_rf(fail_dir)
  FileUtils.mkdir_p(pass_dir)
  FileUtils.mkdir_p(fail_dir)
end
```

### Part C: Test Migration + Classification (30 min)

**Test on IDF first (smallest flavor):**

```bash
# 1. Migrate IDF structure
cd /Users/mulgogi/src/mn/pubid
ruby spec/fixtures/migrate_to_new_structure.rb idf

# 2. Verify new structure created
ls -la spec/fixtures/idf/identifiers/
ls -la spec/fixtures/idf/identifiers/full/

# 3. Check file counts
wc -l spec/fixtures/idf/identifiers/full/*.txt

# 4. Run new classify
ruby spec/fixtures/run_classify.rb idf

# 5. Verify results
ls -la spec/fixtures/idf/identifiers/pass/
ls -la spec/fixtures/idf/identifiers/fail/

# 6. Check statistics
cat spec/fixtures/idf/SUMMARY.txt
```

**Expected Results:**
- `identifiers/full/` contains all unique identifiers
- `identifiers/pass/` contains successful parses (plain + normalized)
- `identifiers/fail/` contains parse errors (errored format)
- Statistics show 100% or close to it for IDF
- Three syntax formats present in files

---

## SESSION 104: Migrate All Flavors (90 minutes)

### Task: Migrate remaining 12 flavors

**Execute migration for each:**
```bash
for flavor in iso iec ieee nist cen bsi jis etsi ccsds itu plateau ansi; do
  echo "Migrating: $flavor"
  ruby spec/fixtures/migrate_to_new_structure.rb $flavor
  echo "Classifying: $flavor"
  ruby spec/fixtures/run_classify.rb $flavor
  echo "---"
done
```

**For each flavor verify:**
1. Backup created (`*_backup_*` directories)
2. New structure exists (`identifiers/{full,pass,fail}`)
3. File counts match (full = pass + fail unique identifiers)
4. Statistics match Session 102 baseline
5. Three syntaxes present

**Expected completion:** All 13 flavors migrated and classified

---

## SESSION 105: Validation + Documentation (60 minutes)

### Part A: Comprehensive Validation (30 min)

**Run classification on all flavors:**
```bash
ruby spec/fixtures/run_classify.rb all
```

**Verify for each flavor:**
1. Count check: `wc -l identifiers/{full,pass,fail}/*.txt`
2. Format check: Spot-check for plain, `!...!`, `#...#` formats
3. Statistics match Session 102:
   - ISO: 98.26% (7,554/7,688)
   - IEC: 99.93% (13,814/13,824)
   - IEEE, NIST, etc.

### Part B: Update Documentation (20 min)

**Update files:**
1. [`FIXTURES_VALIDATION_STATUS.md`](../../docs/FIXTURES_VALIDATION_STATUS.md:1)
   - Document new structure
   - Update statistics
   - Add migration notes

2. Memory bank [`context.md`](context.md:1)
   - Add Session 103-105 summaries
   - Update current status

3. Create `docs/FIXTURES_MIGRATION_GUIDE.md`
   - Document new structure
   - Explain three syntaxes
   - Show examples

### Part C: Final Commit (10 min)

```bash
git add -A
git commit -m "feat: redesign fixtures with identifiers/{full,pass,fail} structure

Sessions 103-105 complete:
- New architecture: identifiers/{full,pass,fail} (non-destructive)
- Three syntaxes: plain, !normalized!, #errored#
- Migration script for all 13 flavors
- Rewritten classify_fixtures.rb
- All flavors validated and working
- Documentation updated

Changes:
- 76 files changed across all flavors
- identifiers/full/ is now source of truth
- pass/fail/ are generated artifacts
- Non-destructive, reproducible workflow

Statistics maintained:
- ISO: 98.26% (7,554/7,688)
- IEC: 99.93% (13,814/13,824)
- Others: maintained or improved"
```

---

## Success Criteria

### Session 103
- ✅ Migration script created and tested on IDF
- ✅ Classify script rewritten with three-syntax support
- ✅ IDF migrated successfully
- ✅ All three syntaxes working

### Session 104
- ✅ All 13 flavors migrated
- ✅ Backups created for all
- ✅ New structure verified for all
- ✅ Statistics maintained

### Session 105
- ✅ Comprehensive validation complete
- ✅ Documentation updated
- ✅ Final commit created
- ✅ Project ready for next phase

---

## Rollback Plan

If issues arise:
1. Backups available in `*_backup_*` directories
2. Git can revert changes
3. Can restore per-flavor if needed
4. Migration is idempotent (can re-run)

---

## Session 103 Start Checklist

1. ✅ Read [`session-102-fixtures-redesign-plan.md`](.kilocode/rules/memory-bank/session-102-fixtures-redesign-plan.md:1)
2. ✅ Read this continuation plan
3. ⏳ Create migration script
4. ⏳ Rewrite classify script
5. ⏳ Test on IDF
6. ⏳ Validate and proceed

**First task:** Create `spec/fixtures/migrate_to_new_structure.rb`
