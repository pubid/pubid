# Session 252 Continuation Prompt

**Quick Start:** Fix remaining 7 BSI integration test failures to achieve 40/40 (100%)

---

## Current Status

- **Tests passing:** 33/40 (82.5%)
- **BSI:** 30/36 (83.3%)
- **CEN:** 3/3 (100%) ✅
- **Architecture:** V2 MODEL-DRIVEN complete

---

## Immediate Tasks (90 minutes)

### 1. Fix National Annex Supplements (40 min) - 4 tests

**Problem:** NA supplements and base supplements get conflated

**Files to modify:**
- [`lib/pubid_new/bsi/parser.rb`](lib/pubid_new/bsi/parser.rb:1) - NA supplement capture
- [`lib/pubid_new/bsi/builder.rb`](lib/pubid_new/bsi/builder.rb:1) - build_national_annex method

**Test:**
```bash
bundle exec rspec spec/integration/bsi_spec.rb:38 spec/integration/bsi_spec.rb:39 spec/integration/bsi_spec.rb:40 spec/integration/bsi_spec.rb:41
```

### 2. Fix ExComm on Consolidated (15 min) - 2 tests

**Problem:** ExComm may duplicate on consolidated identifiers

**File to modify:**
- [`lib/pubid_new/bsi/identifiers/expert_commentary.rb`](lib/pubid_new/bsi/identifiers/expert_commentary.rb:1)

**Test:**
```bash
bundle exec rspec spec/integration/bsi_spec.rb:31 spec/integration/bsi_spec.rb:32
```

### 3. Fix Translation All-Caps (15 min) - 1 test

**Problem:** "SPANISH TRANSLATION" format not parsing

**Files to modify:**
- [`lib/pubid_new/bsi/parser.rb`](lib/pubid_new/bsi/parser.rb:1) - translation rule
- [`lib/pubid_new/bsi/builder.rb`](lib/pubid_new/bsi/builder.rb:1) - translation_upper handling

**Test:**
```bash
bundle exec rspec spec/integration/bsi_spec.rb:44
```

### 4. Final Validation (10 min)

**Run all tests:**
```bash
bundle exec rspec spec/integration/bsi_spec.rb spec/integration/cen_spec.rb
```

**Expected:** 39-40/40 tests passing

---

## Architecture Principles

**MAINTAIN:**
- MODEL-DRIVEN (objects not strings)
- MECE (mutually exclusive, collectively exhaustive)
- Three-layer separation (Parser/Builder/Identifier)
- Component reuse (Amendment/Corrigendum objects)
- Wrapper pattern (NationalAnnex wraps adopted identifier)

---

## Detailed Plan

See: [`.kilocode/rules/memory-bank/session-252-continuation-plan.md`](.kilocode/rules/memory-bank/session-252-continuation-plan.md:1)

---

**Goal:** 40/40 tests passing (100%) with clean V2 architecture! 🎯