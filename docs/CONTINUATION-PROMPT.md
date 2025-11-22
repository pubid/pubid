# PubID v2 Lutaml::Model Migration - Continuation Prompt

## MISSION: Complete ALL Remaining Flavors

**STATUS:** IEC is 100% complete (13,824/13,824 tests).

**YOUR MISSION:** Implement ALL remaining PubID flavors (JIS, ETSI, ITU, IEEE, NIST, CCSDS, ISO, BSI, CEN) following the proven IEC MODEL-DRIVEN architecture pattern.

**DO NOT STOP** until all 10 flavors are at 100% completion.

## Complete List of Remaining Work

### ✅ COMPLETED
1. **IEC** - 13,824/13,824 (100%) ✅

### 🎯 MUST COMPLETE (In Priority Order)

2. **JIS** - Japanese Industrial Standards (START HERE)
   - Estimated: 3-4 days
   - Simpler structure, good starting point

3. **ETSI** - European Telecommunications Standards Institute
   - Estimated: 3-4 days
   - Telecom standards

4. **ITU** - International Telecommunication Union
   - Estimated: 4-5 days
   - Complex: ITU-T, ITU-R series

5. **CCSDS** - Consultative Committee for Space Data Systems
   - Estimated: 2-3 days
   - Space data systems

6. **ISO** - International Organization for Standardization
   - Estimated: 10-15 days
   - MOST COMPLEX: Joint publications (ISO/IEC), many identifier types

7. **BSI** - British Standards Institution
   - Estimated: 3-4 days
   - Can leverage ISO/IEC patterns

8. **CEN** - European Committee for Standardization
    - Estimated: 3-4 days
    - Can leverage ISO/IEC patterns

9. **IEEE** - Institute of Electrical and Electronics Engineers
   - Estimated: 4-5 days
   - Unapproved drafts, amendments

10. **NIST** - US National Institute of Standards and Technology
   - Estimated: 5-6 days
   - Multiple series types, versions


**TOTAL REMAINING: ~35-50 days of work across 9 flavors**

## Essential Reading (Read in Order)

1. **docs/LUTAML-MIGRATION-STATUS.md** - Progress tracker
2. **docs/MIGRATION-CONTINUATION-PLAN.md** - 8-phase checklist & principles
3. **old-docs/IEC-MODEL-DRIVEN-ARCHITECTURE.md** - Complete architecture guide
4. **gems/pubid-{flavor}/lib/pubid/{flavor}/** - v1 implementation for each flavor

## Implementation Instructions

### For Each Flavor, Follow These Steps:

#### 1. Analyze v1 Implementation (1 hour)
```bash
# Example for JIS (replace with current flavor)
ls -la gems/pubid-jis/lib/pubid/jis/
cat gems/pubid-jis/lib/pubid/jis/identifier.rb
head -50 gems/pubid-jis/spec/fixtures/jis-pubids.txt
grep -r "class.*Identifier" gems/pubid-jis/lib/pubid/jis/
```

#### 2. Execute 8-Phase Implementation

From `docs/MIGRATION-CONTINUATION-PLAN.md`:

- **Phase 1:** Architecture Planning (1 day)
- **Phase 2:** Components (0.5 days)
- **Phase 3:** Base Infrastructure (1 day)
- **Phase 4:** Identifier Types (2-3 days)
- **Phase 5:** Parser (1-2 days)
- **Phase 6:** Builder (1-2 days)
- **Phase 7:** Testing & Iteration (1-2 days)
- **Phase 8:** Documentation (0.5 days)

#### 3. Use IEC as Template

Copy patterns from `lib/pubid_new/iec/`:
- identifier.rb
- single_identifier.rb
- supplement_identifier.rb
- parser.rb
- builder.rb
- identifiers/base.rb
- identifiers/* (all types)

#### 4. Test Until 100%

```bash
bundle exec rspec spec/integration/{flavor}_spec.rb
```

Iterate on failures until all tests pass.

#### 5. Update Status & Continue

Update `docs/LUTAML-MIGRATION-STATUS.md` with completion percentage, then **immediately move to next flavor**.

## Core Principles (NEVER VIOLATE)

✅ **MODEL-DRIVEN:** Objects contain objects, NOT strings
✅ **TYPED_STAGES:** Array of TypedStage objects
✅ **MECE:** Each identifier exactly ONE type
✅ **Separation of Concerns:** Parser → Builder → Identifier
✅ **Open/Closed:** New types via classes, not modification

❌ **ANTI-PATTERNS:**
- TYPE_MAP hash lookups
- String-based rendering in attributes
- Hardcoded conditional logic
- Mixing parsing and building

## Success Criteria Per Flavor

- [ ] 100% test pass rate
- [ ] All identifier types implemented
- [ ] MODEL-DRIVEN architecture
- [ ] TYPED_STAGES pattern used
- [ ] Proper separation of concerns
- [ ] No anti-patterns
- [ ] Status doc updated

## After Each Flavor Completes

```bash
# Update completion in:
vim docs/LUTAML-MIGRATION-STATUS.md

# Then IMMEDIATELY start next flavor
# DO NOT STOP until all 9 remaining flavors are complete
```

## Commands Reference

```bash
# Create directory structure
mkdir -p lib/pubid_new/{flavor}/{components,identifiers}

# Run tests
bundle exec rspec spec/integration/{flavor}_spec.rb

# Test specific identifier
bundle exec ruby -e "require './lib/pubid_new'; puts PubidNew::{Flavor}.parse('EXAMPLE:2020').to_s"
```

## Master Timeline

- **JIS:** 3-4 days → Start immediately
- **ETSI:** 3-4 days → After JIS
- **ITU:** 4-5 days → After ETSI
- **CCSDS:** 2-3 days → After ITU
- **ISO:** 10-15 days → After CCSDS (most complex)
- **BSI:** 3-4 days → After ISO
- **CEN:** 3-4 days → After BSI (final)
- **IEEE:** 4-5 days → After CEN
- **NIST:** 5-6 days → After IEEE

**Total: ~35-50 days for ALL 9 remaining flavors**

## End Goal

ALL PubID flavors (10 total including IEC) with:
- ✅ Clean MODEL-DRIVEN architecture
- ✅ 100% test coverage
- ✅ Proper Lutaml::Model usage
- ✅ No legacy anti-patterns
- ✅ Production-ready code

## Reference Patterns from IEC

- **Supplements:** `lib/pubid_new/iec/identifiers/amendment.rb`
- **Wrappers:** `lib/pubid_new/iec/identifiers/vap_identifier.rb`
- **Parser:** `lib/pubid_new/iec/parser.rb`
- **Builder:** `lib/pubid_new/iec/builder.rb`
- **TYPED_STAGES:** Any identifier in `lib/pubid_new/iec/identifiers/*.rb`

## DO NOT STOP

Work through ALL 9 remaining flavors systematically. The IEC pattern is proven at 100% - just replicate it for each flavor.

JIS → ETSI → ITU → CCSDS → ISO → BSI → CEN → IEEE → NIST

Complete them ALL! 🚀
