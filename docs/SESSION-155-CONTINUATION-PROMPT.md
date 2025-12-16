# Session 155 Quick Start: API to 100%

**Read First:** [`docs/SESSION-155-CONTINUATION-PLAN.md`](SESSION-155-CONTINUATION-PLAN.md:1) (comprehensive plan)

---

## Session 155 Goal: API 100% (60 minutes)

### Context
Session 154 completed:
- **API:** 197/215 (91.63%) - Need +18 for 100%
- **CSA:** 471/936 (50.32%) - Will tackle in Sessions 156-159

**Only 18 API failures remaining!**

---

## Part A: Extract All API Failures (10 min)

```bash
cat > /tmp/api_all_failures.rb << 'EOF'
require 'parslet'
require_relative '/Users/mulgogi/src/mn/pubid/lib/pubid_new/api'

fixtures = File.readlines('/Users/mulgogi/src/mn/pubid/spec/fixtures/api/identifiers/full/identifiers.txt').map(&:strip).reject(&:empty?)

puts "All 18 API failures:"
puts "="*60

fixtures.each do |id|
  begin
    PubidNew::Api.parse(id)
  rescue => e
    puts id
  end
end
EOF
ruby /tmp/api_all_failures.rb
```

---

## Part B: Pattern Analysis (20 min)

Group failures by type:
1. **Combined identifiers** (e.g., `COS 1-07/RP 75, 4th edition`)
2. **Edition notation** (e.g., `, Nth edition`)
3. **Other patterns**

Count each pattern type to prioritize.

---

## Part C: Implementation (30 min)

Focus on the most common pattern first.

**Most likely: Combined identifiers with slash**
- Pattern: `TYPE1 NUM1-YY/TYPE2 NUM2`
- Update [`lib/pubid_new/api/parser.rb`](lib/pubid_new/api/parser.rb:1)
- Add combined_identifier rule

**Test after each change:**
```bash
ruby /tmp/count_api.rb
```

---

## Testing Commands

```bash
# Count progress
ruby /tmp/count_api.rb

# See remaining failures
ruby /tmp/api_all_failures.rb

# Both together
ruby /tmp/count_api.rb && echo "" && ruby /tmp/api_all_failures.rb | wc -l
```

---

## Success Criteria

- ✅ API: 215/215 (100%)
- ✅ All patterns working
- ✅ Round-trip fidelity maintained
- ✅ Architecture clean (MODEL-DRIVEN, MECE)

---

Good luck with Session 155 - API to 100%! 🚀