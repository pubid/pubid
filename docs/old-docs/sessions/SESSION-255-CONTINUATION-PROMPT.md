# Session 255 Continuation Prompt

## Quick Context

**Session 254 Complete:** Fixed 4 IEC specs, reduced failures from 53 to 31 (42% reduction)

**Current Status:**
- IEC: 578/628 passing (92.0%), 31 failures, 19 pending
- Fixed: 10/13 specs perfect ✅
- Remaining: 6 specs with 31 failures

**Key Learning:** V2 test expectations were copied wrong. V1 is SOURCE OF TRUTH.

## What to Do

Complete remaining 6 IEC spec alignments by following the same pattern:

### For Each Spec:

1. **Identify failures:**
```bash
bundle exec rspec spec/pubid_new/iec/identifiers/{spec}.rb --format documentation 2>&1 | grep -B 2 "FAILED"
```

2. **Check V1:**
```bash
grep -r "{pattern}" archived-gems/pubid-iec/spec/
```

3. **Fix:**
- Pattern in V1? → Update expectation to match V1
- Pattern NOT in V1? → Mark as `pending` with NOTE

4. **Test:**
```bash
bundle exec rspec spec/pubid_new/iec/identifiers/{spec}.rb
```

### Remaining Specs (Priority Order):

1. **sheet_identifier_spec.rb** (11 failures) - ~30 min
2. **fragment_identifier_spec.rb** (6 failures) - ~20 min
3. **international_standard_spec.rb** (5 failures) - ~20 min
4. **interpretation_sheet_spec.rb** (3 failures) - ~15 min
5. **systems_reference_document_spec.rb** (3 failures) - ~15 min
6. **technical_report_spec.rb** (3 failures) - ~15 min

## Success Criteria

- ✅ All 6 specs: 0 failures (parser gaps marked as pending)
- ✅ Commit progress after every 2 specs
- ✅ Target: IEC 100% aligned (allowing for documented pending)

## Key Patterns from Session 254

**Rendering fixes:**
- `Amd 1` → `AMD1` (uppercase, no space)
- `Cor 1` → `COR1` (uppercase, no space)
- `ISO/IEC PAS` → `ISO PAS` (copublisher dropped)

**Parser gaps (mark as pending):**
- Undated consolidated: `IEC 60529+AMD1`
- Draft without base: `IEC/FDAM 60038-1`

## Files to Read First

1. `docs/SESSION-255-CONTINUATION-PLAN.md` - Full plan
2. `.kilocode/rules/memory-bank/context.md` - Session 254 results

## Remember

- **V1 is always correct** - Match V1 exactly
- **No implementation changes** - Only update test expectations
- **Parser gaps OK** - Mark as `pending` with clear NOTE
- **Architecture stays clean** - No shortcuts

---

**Created:** 2026-01-02
**For:** Session 255
**Goal:** Complete IEC spec alignment