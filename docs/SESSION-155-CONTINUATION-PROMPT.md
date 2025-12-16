# Session 155 ULTRA-COMPRESSED: API & CSA to 100% in One Session!

**Read First:** [`docs/SESSION-155-CONTINUATION-PLAN.md`](SESSION-155-CONTINUATION-PLAN.md:1) (detailed strategy)

---

## Session 155 Goal: BOTH to 100% (2.5-3 hours)

**Ultra-aggressive timeline:** API first (30-45 min), then CSA blitz (2 hours)

### Current Status
- **API:** 197/215 (91.63%) → 18 IDs to 100%
- **CSA:** 471/936 (50.32%) → 465 IDs to 100%

---

## PART A: API to 100% (30-45 minutes) ⚡

### 1. Extract all 18 failures (5 min)
```bash
cat > /tmp/api_all_failures.rb << 'EOF'
require 'parslet'
require_relative '/Users/mulgogi/src/mn/pubid/lib/pubid_new/api'
fixtures = File.readlines('/Users/mulgogi/src/mn/pubid/spec/fixtures/api/identifiers/full/identifiers.txt').map(&:strip).reject(&:empty?)
puts "All API failures:"; puts "="*60
fixtures.each { |id| puts id unless (PubidNew::Api.parse(id) rescue nil) }
EOF
ruby /tmp/api_all_failures.rb
```

### 2. Identify pattern (5 min)
Count pattern types manually from output.

### 3. Implement & test (20-35 min)
Update [`lib/pubid_new/api/parser.rb`](lib/pubid_new/api/parser.rb:1), test: `ruby /tmp/count_api.rb`

**Target:** 215/215 (100%) ✅

---

## PART B: CSA Pattern Blitz (2 hours) 🔥

### 1. Analyze ALL 465 failures (15 min)
```bash
cat > /tmp/csa_pattern_analysis.rb << 'EOF'
require 'parslet'
require_relative '/Users/mulgogi/src/mn/pubid/lib/pubid_new/csa'
fixtures = File.readlines('/Users/mulgogi/src/mn/pubid/spec/fixtures/csa/identifiers/full/identifiers.txt').map(&:strip).reject(&:empty?)
failures = fixtures.select { |id| !(PubidNew::Csa.parse(id) rescue nil) }
patterns = Hash.new(0)
failures.each do |id|
  case id
  when /\(R\d{4}\)/ then patterns["Reaffirmation (RXXXX)"] += 1
  when /NO\.\s+\d+/ then patterns["NO. keyword"] += 1
  when /PACKAGE/ then patterns["PACKAGE keyword"] += 1
  when /\(R\d{2}\)/ then patterns["Reaffirmation 2-digit"] += 1
  else patterns["Other"] += 1
  end
end
puts "="*60; puts "CSA Pattern Frequency"; puts "="*60
patterns.sort_by { |k,v| -v }.each { |k,v| puts "#{k}: #{v}" }
puts "="*60; puts "Total: #{failures.count}"
EOF
ruby /tmp/csa_pattern_analysis.rb
```

### 2. Batch 1: Top 2-3 patterns (30 min)
Implement highest-frequency patterns in [`lib/pubid_new/csa/parser.rb`](lib/pubid_new/csa/parser.rb:1)
Test: `ruby /tmp/count_csa.rb`
**Target:** 70%+ (656+/936)

### 3. Batch 2: Next 2-3 patterns (30 min)
Continue with next-highest frequency
**Target:** 85%+ (796+/936)

### 4. Final sweep: All remaining (45 min)
Systematic implementation of all remaining patterns
**Target:** 100% (936/936) ✅

---

## Quick Commands

```bash
# API progress
ruby /tmp/count_api.rb

# CSA progress
ruby /tmp/count_csa.rb

# Both together
echo "=== API ===" && ruby /tmp/count_api.rb && echo "" && echo "=== CSA ===" && ruby /tmp/count_csa.rb
```

---

## Success Criteria

- ✅ API: 215/215 (100%)
- ✅ CSA: 936/936 (100%)
- ✅ Total time: <3 hours
- ✅ Architecture: MODEL-DRIVEN maintained

---

**GO FAST! Data-driven pattern prioritization is key!** 🚀