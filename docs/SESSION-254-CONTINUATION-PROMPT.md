# Session 254 Continuation Prompt

## Quick Context

**Session 253 Learning:** V2 test expectations were copied incorrectly from V1. The actual implementations are mostly correct - it's the TEST EXPECTATIONS that are wrong.

**Key Principle:** 
```
V1 specs (archived-gems/pubid-{flavor}/spec/) = SOURCE OF TRUTH
V2 specs (spec/pubid_new/{flavor}/) = Should match V1 exactly
```

## What to Do

For each flavor (IEC, IEEE, NIST, JIS, etc.), systematically:

1. **Find V1 spec**: `archived-gems/pubid-{flavor}/spec/pubid_{flavor}/identifier_spec.rb`
2. **Find V2 spec**: `spec/pubid_new/{flavor}/identifier_spec.rb`  
3. **Compare expectations**: What does V1 expect `.to_s` to return?
4. **Update V2**: Make V2 expectations match V1 exactly
5. **Test**: Run V2 spec, verify it passes

## Example Workflow

```bash
# Step 1: Check what V1 expects
grep -A 5 'to_s' archived-gems/pubid-iec/spec/pubid_iec/identifier_spec.rb | head -20

# Step 2: Compare with V2
grep -A 5 'to_s' spec/pubid_new/iec/identifier_spec.rb | head -20

# Step 3: If different, update V2 to match V1
# (use edit_file tool)

# Step 4: Test
bundle exec rspec spec/pubid_new/iec/identifier_spec.rb
```

## ISO Special Note

For ISO flavor specifically, there are 5 known architectural issues (dot preservation, French Guide, NSB, etc.). These cause fixture tests to fail, but that's **ACCEPTABLE FOR NOW**. Don't try to fix the implementation - just document the known issues.

The individual identifier specs (amendment_spec.rb, etc.) should still be updated to match V1 behavior where possible.

## Priority Order

1. **IEC** - Large flavor, important
2. **IEEE** - Large flavor, high usage  
3. **NIST** - Already at 99.98%, verify specs match
4. **JIS** - Verify specs
5. **Others** - As time permits

## Success Criteria

- ✅ V2 spec expectations match V1
- ✅ No implementation changes (architecture stays clean)
- ✅ Tests pass or documented reasons for failure
- ✅ Zero brute-force hacks

## Files to Read First

1. `.kilocode/rules/memory-bank/session-254-continuation-plan.md` - This plan
2. `docs/SESSION-254-FIXTURE-ROUNDTRIP-ANALYSIS.md` - ISO issues analysis
3. `.kilocode/rules/memory-bank/context.md` - Session 253 summary

## Time Estimate

- Analysis per flavor: 15-20 min
- Updates per flavor: 30-40 min  
- Testing per flavor: 10 min
- **Total per flavor:** ~1 hour
- **4-5 flavors:** 4-5 hours

Start with IEC and work systematically!

---

**Created:** 2026-01-02
**For:** Session 254
**Approach:** Systematic V1→V2 spec alignment
**Key:** V1 is ALWAYS correct! 🎯
