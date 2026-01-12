# Session 295: BSI & CEN Implementation Continuation

**Objective:** Fix CEN parser to unblock ~100 BSI patterns, then continue BSI implementation to reach 85%+ coverage.

## Current Status

**BSI V2 Coverage:** 1,285/1,632 (78.74%)
**Integration Tests:** 174/174 pass, 6 pending

### 100% Categories (7)
- supplement, addendum, range, publicly_available_specification
- handbook, practice_guide, quality_control

### Blocking Issue
**CEN parser missing CR type** - Blocks ~100 DD/PD patterns like:
- `DD CR 13933:2000`
- `PD CR 14587:2000`
- `DD CEN/TS 15119-1:2008`

## Priority 1: Fix CEN Parser (HIGH)

### Steps

1. **Read CEN Parser & Scheme:**
   ```
   lib/pubid_new/cen/parser.rb
   lib/pubid_new/cen/scheme.rb
   lib/pubid_new/cen/identifiers/
   ```

2. **Create CenReport Class:**
   ```ruby
   # lib/pubid_new/cen/identifiers/cen_report.rb
   class CenReport < SingleIdentifier
     TYPED_STAGES = [
       TypedStage.new(code: :cr, type_code: :cr, abbr: ["CR"])
     ].freeze
   end
   ```

3. **Update CEN Parser:**
   - Add `CR` type rule
   - Handle `CEN ISO/TS` pattern

4. **Update CEN Scheme:**
   - Register CenReport in typed stages
   - Add to identifier class map

5. **Test with BSI:**
   ```bash
   ruby test_bsi_full_coverage.rb
   ```

**Expected:** +50-80 patterns in DD/PD categories

## Priority 2: Create Missing BSI Classes (MEDIUM)

### Categories at 0%
- Electronic Book (20 patterns)
- Index (13 patterns)
- Method (14 patterns)
- Section (11 patterns)

### Approach
1. Analyze fixture file patterns
2. Create identifier class inheriting from SingleIdentifier
3. Add TYPED_STAGES constant
4. Implement `to_s` for round-trip
5. Register in scheme

## Priority 3: Edge Cases (LOW)

- Standalone AMD patterns
- Expert Commentary variants
- 2X prefix for aerospace

## Files to Read First

```
lib/pubid_new/cen/parser.rb
lib/pubid_new/cen/scheme.rb
lib/pubid_new/cen/identifiers/
spec/fixtures/bsi/identifiers/full/draft_document.txt
spec/fixtures/bsi/identifiers/full/published_document.txt
```

## Validation Commands

```bash
# BSI coverage after CEN fix
ruby test_bsi_full_coverage.rb

# CEN tests
bundle exec rspec spec/pubid_new/cen/

# BSI integration tests
bundle exec rspec spec/pubid_new/bsi/
```

## Success Criteria

- [ ] CEN CR type implemented and working
- [ ] BSI DD/PD coverage improved (unblock CEN adoptions)
- [ ] Overall BSI coverage: 78% → 85%+
- [ ] All 174 BSI integration tests pass or pending

## Architecture Reminders

- **MODEL-DRIVEN:** All identifiers inherit from Base
- **Three-layer:** Parser → Builder → Identifier
- **TYPED_STAGES:** Use TypedStage array, not hash maps
- **Round-trip:** `parse(str).to_s == str`

---

**These instructions supersede any conflicting general instructions.**
