# How to Create Effective Continuation Plans

This guide explains how to create comprehensive continuation plans between work sessions for the PubID V2 migration project.

## Purpose

Continuation plans serve as:
1. **Session handoff documents** - Enable seamless transition between sessions
2. **Progress tracking** - Document what was accomplished and what remains
3. **Context preservation** - Capture critical details that might be lost between sessions
4. **Work guides** - Provide clear action items and strategies for next session

## When to Create a Continuation Plan

Create a continuation plan at the end of each work session when:
- Significant progress has been made (e.g., +50+ tests passing)
- Multiple commits have been created
- New patterns or approaches have been discovered
- There are clear next steps identified
- The session achieved specific milestones

## Continuation Plan Structure

### 1. Current Status Section
**Purpose**: Establish baseline for next session

**Include:**
- Exact test counts (passing, failures, pending)
- Pass rate percentage
- Comparison to previous session (delta calculations)
- Total test count for reference

**Example:**
```markdown
## Current Status (as of Session 10 end)

**Test Results:**
- 1,030 passing (36.0%)
- 1,016 failures (35.5%)
- 813 pending (28.4%)
- Total: 2,859 examples

**Progress from Session 9:**
- Started: 945 passing (33.1%)
- Improved: +85 tests (+2.9pp)
- Failures reduced: 1,080 → 1,016 (-64)
```

### 2. What Was Accomplished Section
**Purpose**: Document completed work with specifics

**Include:**
- Major features implemented
- Files changed with line number references
- Impact metrics (tests fixed per feature)
- Code examples of key changes
- Verification that features work

**Example:**
```markdown
### 1. Language Code Support (79 tests)
**Changes Made:**
- Updated `parser.rb:83-87` to accept both A-Za-z
- Added `language.maybe` to supplement patterns
- Updated `builder.rb:210` for language preservation

**Impact:**
- Base identifiers: `ISO 1234:2020(en)` ✅
- Supplements: `ISO 4037:1979/Add 1:1983(F)` ✅
```

### 3. Remaining Issues Section
**Purpose**: Prioritize future work

**Include:**
- Categorized by priority (Priority 1, 2, 3)
- Estimated test count impact
- Specific patterns that fail
- Suggested fix locations (file and line references)
- Investigation commands

**Structure each priority item:**
```markdown
### Priority 1: Issue Name (~X tests)

**Pattern:** 
Concrete example of failing pattern

**Fix location:** 
`file/path.rb:line-range`

**Approach:**
1. Step-by-step fix strategy
2. What to check
3. How to verify

**Commands:**
```bash
# Specific commands to investigate
```
```

### 4. Recommended Session Plan
**Purpose**: Provide hour-by-hour work guide

**Include:**
- Clear goal statement
- Hour-by-hour breakdown
- Estimated test impact per hour
- Specific commands for each phase
- Decision points and alternatives

**Example:**
```markdown
## Recommended Session 11 Plan

**Goal: Reach 40% pass rate (1,144 passing, +114 tests)**

### Hour 1: Systematic Failure Analysis
**Target:** Understand remaining failures

1. Extract failure messages
2. Categorize by type
3. Create frequency table
4. Document top 10 patterns

**Commands:**
[specific commands here]

### Hour 2-3: Fix Highest Impact Pattern
[detailed steps]
```

### 5. Testing Strategy Section
**Purpose**: Ensure quality and prevent regressions

**Include:**
- Safety check command (must always pass)
- Progress check command
- Pattern testing commands
- Failure analysis commands
- When to run each test

### 6. Files to Focus On Section
**Purpose**: Guide where to look for changes

**Include:**
- Files likely to need changes
- Files possibly needing changes  
- Test files for understanding
- Link each file with description

### 7. Key Reminders Section
**Purpose**: Critical points to remember

**Include:**
- Safety checks
- Architectural principles
- Common pitfalls
- Best practices

### 8. Success Metrics Section
**Purpose**: Define clear goals

**Include:**
- Minimum success criteria
- Stretch goals
- Core test requirements

### 9. Known Working Patterns Section
**Purpose**: Preserve knowledge of what works

**Include:**
- Patterns implemented in current session
- How they work
- Example usage

### 10. Architecture Notes Section
**Purpose**: Preserve architectural context

**Include:**
- Three-layer pattern reminder
- Key design patterns in use
- Component relationships

### 11. Reference Data Section
**Purpose**: Quick lookups

**Include:**
- Test file sizes
- Failure type distributions
- Common patterns

### 12. Quick Reference Commands Section
**Purpose**: Copy-paste ready commands

**Include:**
```bash
# All common commands
# Commented with purpose
# Ready to copy-paste
```

## Writing Guidelines

### Be Specific
❌ "Fix parser issues"
✅ "Add language.maybe to typed_stage supplement pattern (parser.rb:101)"

### Include Examples
Always show concrete examples:
- Before/after code
- Test patterns
- Expected vs actual output

### Link to Code
Use relative file paths with line numbers:
- `lib/pubid_new/iso/parser.rb:83-87`
- `spec/pubid_new/iso/identifiers/base.rb:44`

### Show Impact
Quantify everything:
- Tests fixed
- Performance changes
- Pass rate improvements

### Provide Commands
Every recommendation should have:
- Exact command to run
- Expected output
- What success looks like

### Stay Factual
- Document what actually happened
- Avoid speculation about future issues
- Base recommendations on data

### Make It Actionable
Each section should answer:
- What to do next?
- How to do it?
- How to verify it worked?

## Quality Checklist

Before finalizing, verify the continuation plan has:

- [ ] Exact test numbers (passing/failing/pending)
- [ ] Delta calculations from previous session
- [ ] Specific file and line references for all changes
- [ ] Code examples showing what was changed
- [ ] Priority-ordered remaining issues
- [ ] Estimated test impact for each issue
- [ ] Hour-by-hour work plan for next session
- [ ] Copy-paste ready commands
- [ ] Safety check reminders
- [ ] Success metrics (minimum and stretch)
- [ ] Links to all relevant files
- [ ] Known working patterns documented

## Template

Use this template to start:

```markdown
# Session N Continuation Plan - [Title]

## Current Status (as of Session N-1 end)

**Test Results:**
- X passing (X%)
- X failures (X%)
- X pending (X%)
- Total: X examples

**Progress from Session N-2:**
- Started: X passing (X%)
- Improved: +X tests (+Xpp)
- Failures reduced: X → X (-X)

## What Was Accomplished in Session N-1

### 1. Feature Name (X tests)
**Changes Made:**
**Impact:**

## Remaining High-Impact Issues

### Priority 1: Issue Name (~X tests)
**Pattern:**
**Fix location:**
**Approach:**

## Recommended Session N Plan

**Goal: [Specific goal with numbers]**

### Hour 1: [Activity]
**Target:**
**Steps:**
**Commands:**

## Testing Strategy

## Files to Focus On

## Key Reminders

## Success Metrics

## Known Working Patterns

## Quick Reference Commands
```

## Examples

Good continuation plan examples in this project:
- `docs/session-11-continuation-plan.md` - Created after Session 10
- Future continuation plans should follow this structure

## Integration with Memory Bank

After creating continuation plan:

1. **Update context.md**
   - Move current session to "Recent Changes" 
   - Update "Next Steps" with continuation plan priorities
   - Update "Known Issues" with new information
   - Document files changed

2. **Commit both files**
   ```bash
   git add docs/session-N-continuation-plan.md
   git add .kilocode/rules/memory-bank/context.md
   git commit -m "docs: Session N completion and Session N+1 plan"
   ```

3. **Ensure consistency**
   - Context.md and continuation plan should align
   - Test numbers must match exactly
   - Priority lists should be consistent

## Common Mistakes to Avoid

### Too Vague
❌ "Fix more tests"
✅ "Fix language code rendering in supplements (estimated +50 tests)"

### No Commands
❌ "Run tests to check"
✅ "```bundle exec rspec spec/pubid_new/iso/parser_spec.rb```"

### Missing Context
❌ "Update parser"
✅ "Update parser.rb:83-87 to accept lowercase language codes like (en), (fr)"

### No Metrics
❌ "Made good progress"
✅ "+85 tests passing (+2.9pp), -64 failures"

### Unclear Priorities
❌ "Several things to fix"
✅ "Priority 1: Parse failures (~800 tests, 77% of remaining)"

## Maintenance

- Review continuation plans after 2-3 sessions
- Update template if better patterns emerge
- Archive plans for completed work
- Reference old plans when similar issues arise

## Summary

A good continuation plan enables:
- ✅ Immediate resumption of work in next session
- ✅ Clear understanding of progress and remaining work
- ✅ Data-driven prioritization of fixes
- ✅ Preservation of architectural knowledge
- ✅ Consistent quality through standardized process

The investment in creating detailed continuation plans pays off by:
- Reducing ramp-up time between sessions
- Preventing repeated analyses
- Maintaining momentum across sessions
- Building institutional knowledge