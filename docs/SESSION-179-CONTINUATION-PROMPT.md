# Session 179 Continuation Prompt

## Context

Session 178 completed AIEE combined identifiers and verified IEEE/ASTM SI/PSI patterns. IEEE remains at 90.16% (8,612/9,552).

**Current TODO Status:** 37/46 patterns complete (80%)
**Remaining:** 9 patterns, compressed timeline for completion

## Session 179 Objective

Implement **combined identifier with supplements** pattern to handle:

```
IEEE Std 802.16e-2005 and IEEE Std 802.16-2004/Cor 1-2005 (Amendment and Corrigendum to IEEE Std 802.16-2004)
```

**Pattern:** "X and Y/Cor Z" where second identifier has corrigendum supplement
**Challenge:** Parser needs to handle "and" separator with complex supplements
**Expected gain:** +1 identifier (Line 12)

## Implementation Tasks

### 1. Parser Enhancement (40 min)

Add to `lib/pubid_new/ieee/parser.rb`:

```ruby
# Combined identifier with supplements
rule(:combined_identifier_with_supplements) do
  identifier.as(:first) >>
  space >> str("and") >> space >>
  identifier.as(:second) >>
  parenthetical.maybe
end
```

Update `identifier` rule to try this pattern before generic patterns.

### 2. Builder Enhancement (30 min)

Add to `lib/pubid_new/ieee/builder.rb`:

```ruby
def build_combined_with_supplements(parsed)
  first_id = build_single_identifier(parsed[:first])
  second_id = build_single_identifier(parsed[:second])

  Identifiers::DualPublished.new(
    first_identifier: first_id,
    second_identifier: second_id,
    separator: " and "
  )
end
```

### 3. Testing (20 min)

Test pattern and verify no regressions:
```ruby
PubidNew::Ieee.parse("IEEE Std 802.16e-2005 and IEEE Std 802.16-2004/Cor 1-2005 (...)")
```

## Success Criteria

- ✅ Line 12 pattern parsing correctly
- ✅ No regressions in existing combined identifiers
- ✅ IEEE at 8,613+/9,552 (90.17%+)
- ✅ Clean MODEL-DRIVEN architecture maintained

## Files to Read

Before implementing, read:
1. `lib/pubid_new/ieee/parser.rb` (lines 625-660 - identifier rule)
2. `lib/pubid_new/ieee/builder.rb` (lines 120-130 - build_dual_published)
3. `TODO.IEEE-MUST-DO.txt` (line 12)

## Files to Modify

1. `lib/pubid_new/ieee/parser.rb` - Add combined_identifier_with_supplements rule
2. `lib/pubid_new/ieee/builder.rb` - Add build handler
3. `TODO.IEEE-MUST-DO.txt` - Mark line 12 complete after testing

## Next Session

After Session 179, proceed to Session 180 for complex amendment list verification (Line 17).

---
**Timeline:** 90 minutes compressed
**Status:** Ready for implementation