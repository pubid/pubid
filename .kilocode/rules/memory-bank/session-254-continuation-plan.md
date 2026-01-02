# Session 254+ Continuation Plan: V1 to V2 Spec Alignment

**Created:** 2026-01-02 (Post-Session 253)
**Status:** Analysis complete - V2 specs need alignment with V1
**Timeline:** SIMPLE - Update specs to match V1 expectations

---

## Executive Summary

**Session 253 Learning:** V1 specs are CORRECT. V2 specs copied expectations incorrectly.

**Key Principle:** For every spec in V1 `archived-gems/pubid-{flavor}/spec/`, find the corresponding spec in V2 `spec/pubid_new/{flavor}/`, and ensure expectations match V1.

**V1 is the source of truth** - V2 must match V1 behavior exactly.

---

## Correct Approach

### For All Flavors:

1. **Read V1 spec** in `archived-gems/pubid-{flavor}/spec/`
2. **Find V2 spec** in `spec/pubid_new/{flavor}/`
3. **Compare expectations** - what does V1 expect for `.to_s`, `.to_s(format:)`, etc.?
4. **Update V2 spec** to match V1 expectations exactly
5. **If V2 spec missing** - create it based on V1

### V1 Rendering Contract (ISO example):

```ruby
# V1 default rendering
id.to_s  # Preserves original format (round-trip)
id.to_s(format: :ref_dated_long)  # Also preserves original (default format)

# V1 normalized rendering
id.to_s(format: :ref_num_long)  # 2-letter lang codes, long stage form
id.to_s(format: :ref_num_short)  # 1-letter lang codes, short stage form

# V1 edition
id.to_s(with_edition: true)  # Shows edition number, still round-trips other aspects
```

**CRITICAL:** `with_edition` is about **showing edition number**, NOT normalization!

---

## ISO Specific Issues (DEFER for now)

These are real architectural issues in V2 implementation, but can be fixed later:

1. ~~TypedStage dot preservation~~ - Skip for now, normalize is acceptable
2. ~~French Guide ordering~~ - Skip for now
3. ~~NSB parsing~~ - Skip for now
4. ~~Multilingual publishers~~ - Skip for now
5. ~~Directives format~~ - Skip for now

**Fixture tests may fail** due to these issues, but that's acceptable for now.

---

## Next Steps

**For other flavors (not ISO)**, systematically:

1. Check if V1 spec exists for that flavor
2. Compare with V2 spec
3. Update V2 spec expectations to match V1
4. Add missing V2 specs where needed

**Example workflow:**
```bash
# Compare IEC specs
diff archived-gems/pubid-iec/spec/pubid_iec/identifier_spec.rb \
     spec/pubid_new/iec/identifier_spec.rb

# Update V2 expectations to match V1
# ...
```

---

## Files Modified (Session 253)

None - all incorrect changes were reverted ✅

---

## Files to Create

- Session 254+ work will create/update V2 specs to match V1

---

## Success Criteria

- ✅ V1 specs analyzed
- ✅ V2 specs match V1 expectations
- ✅ No brute-force implementation changes
- ✅ Architecture stays clean

---

**Created:** 2026-01-02
**Status:** Ready for systematic V1→V2 spec alignment
**Key Principle:** V1 specs are CORRECT - match them exactly! 🎯
