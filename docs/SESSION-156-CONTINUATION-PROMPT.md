# Session 156 CRITICAL: Fix CSA Bundled Identifier Semantic Error

**Read First:** [`docs/SESSION-156-CONTINUATION-PLAN.md`](SESSION-156-CONTINUATION-PLAN.md:1) (detailed plan)

---

## CRITICAL ISSUE: Semantic Error in Session 155

❌ **Wrong:** Converting `+` to `/` loses semantic meaning
✅ **Right:** `+` = BundledIdentifier (different class, different meaning)

**Pattern:** `CSA C22.2 NO. 60601-1:14 + A2:22 (R2022)`
**Meaning:** Base bundled with amendment, reaffirmed 2022
**NOT:** Base with amendment reference

---

## Session 156 Tasks (2 hours)

### 1. Revert + Preprocessing (5 min) ⚡
```ruby
# In lib/pubid_new/csa/parser.rb - REMOVE this line:
normalized = normalized.gsub(" + ", "/")
```

### 2. Create BundledIdentifier Class (30 min)
- File: `lib/pubid_new/csa/identifiers/bundled.rb`
- Inherit from Identifier
- Attributes: base, bundled_with (collection), reaffirmed
- Render: `base + bundled1 + bundled2 (R20XX)`

### 3. Add Bundled Parser Pattern (45 min)
- File: `lib/pubid_new/csa/parser.rb`
- New rules: `plus`, `bundled_portion`, `bundled_identifier`
- Bundled portion: Just `A2:22` (base implied)
- Priority: Before combined_slash in identifier rule

### 4. Builder Enhancement (30 min)
- File: `lib/pubid_new/csa/builder.rb`
- Add `build_bundled` method
- Recursively parse base
- Build bundled amendments with implied base

### 5. Test (10 min)
```bash
ruby /tmp/count_csa.rb  # Target: 66%+ (626+/936)
```

---

## Key Points

1. **Semantic correctness > Test count**
2. **+ ≠ /** - Different document structures
3. **MODEL-DRIVEN** - Proper class for bundled type
4. **Round-trip fidelity** - Must preserve `+` notation

---

**Target:** CSA 66%+ with correct semantics
**Next:** Session 157 for remaining patterns (Amendment after reaffirmation, PACKAGE, etc.)