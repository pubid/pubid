# PubID v2 Lutaml::Model Migration - Continuation Prompt

## Quick Start for Next AI Session

**STATUS:** IEC is 100% complete. Ready to start JIS implementation.

**Your Task:** Implement JIS flavor following the proven IEC MODEL-DRIVEN architecture pattern.

## Essential Reading (in order)

1. **docs/LUTAML-MIGRATION-STATUS.md** - Current progress tracker
2. **docs/MIGRATION-CONTINUATION-PLAN.md** - Implementation checklist & principles
3. **old-docs/IEC-MODEL-DRIVEN-ARCHITECTURE.md** - Complete architecture guide from IEC
4. **gems/pubid-jis/lib/pubid/jis/** - v1 JIS implementation to understand

## Step-by-Step Instructions

### 1. Understand JIS Requirements (30 min)
```bash
# Read the v1 implementation
ls -la gems/pubid-jis/lib/pubid/jis/
cat gems/pubid-jis/lib/pubid/jis/identifier.rb

# Review test fixtures
head -20 gems/pubid-jis/spec/fixtures/jis-pubids.txt

# Check what identifier types exist
grep -r "class.*Identifier" gems/pubid-jis/lib/pubid/jis/
```

### 2. Follow the 8-Phase Checklist

From `docs/MIGRATION-CONTINUATION-PLAN.md`, execute:

**Phase 1: Architecture Planning (1 day)**
- List all JIS identifier types
- Identify SingleIdentifier vs SupplementIdentifier hierarchy
- Plan components (Publisher, Code, etc.)

**Phase 2-8:** Follow checklist exactly as documented

### 3. Copy IEC Pattern

The IEC implementation is your template:
```bash
# Use these as reference:
lib/pubid_new/iec/identifier.rb
lib/pubid_new/iec/single_identifier.rb
lib/pubid_new/iec/parser.rb
lib/pubid_new/iec/builder.rb
lib/pubid_new/iec/identifiers/base.rb
```

### 4. Key Principles (NEVER VIOLATE)

✅ **MODEL-DRIVEN:** Objects contain objects, NOT strings
✅ **TYPED_STAGES:** Use array of TypedStage objects
✅ **MECE:** Each identifier is exactly ONE type
✅ **Separation of Concerns:** Parser → Builder → Identifier
✅ **Open/Closed:** New types via classes, not modification

❌ **ANTI-PATTERNS TO AVOID:**
- TYPE_MAP hash lookups
- String-based rendering in attributes
- Hardcoded conditional logic for specific cases
- Mixing parsing and building logic

## Integration Test Command

```bash
cd /Users/mulgogi/src/mn/pubid && bundle exec rspec spec/integration/jis_spec.rb
```

Monitor progress by category and fix issues iteratively.

## Success Criteria

- [ ] 100% test pass rate
- [ ] All JIS identifier types implemented
- [ ] MODEL-DRIVEN architecture (objects, not strings)
- [ ] TYPED_STAGES pattern used throughout
- [ ] Proper separation of concerns
- [ ] No anti-patterns present
- [ ] Documentation updated in docs/LUTAML-MIGRATION-STATUS.md

## After JIS Completes

Update status tracker:
```bash
# Update completion percentage in:
docs/LUTAML-MIGRATION-STATUS.md

# Then continue to next flavor (ETSI) using same pattern
```

## Need Help?

Reference these patterns from IEC:
- **Supplement handling:** `lib/pubid_new/iec/identifiers/amendment.rb`
- **Wrapper pattern:** `lib/pubid_new/iec/identifiers/vap_identifier.rb`
- **Parser rules:** `lib/pubid_new/iec/parser.rb`
- **Builder logic:** `lib/pubid_new/iec/builder.rb`
- **TYPED_STAGES:** Any `lib/pubid_new/iec/identifiers/*.rb` file

## Commands Reference

```bash
# Create directory structure
mkdir -p lib/pubid_new/jis/{components,identifiers}

# Run tests
bundle exec rspec spec/integration/jis_spec.rb

# Check specific category
bundle exec rspec spec/integration/jis_spec.rb -e "category_name"

# Test specific identifier
bundle exec ruby -e "require './lib/pubid_new'; puts PubidNew::Jis.parse('JIS A 1234:2020').to_s"
```

## Timeline

- **JIS:** 3-4 days (simpler than IEC)
- **Each subsequent flavor:** 2-6 days
- **Total remaining:** ~35-50 days for all flavors

## End Goal

All PubID flavors with:
- Clean MODEL-DRIVEN architecture
- 100% test coverage  
- Proper Lutaml::Model usage
- No legacy anti-patterns
- Production-ready code

Good luck! The IEC pattern is proven to work at 100%. Just follow it carefully.
