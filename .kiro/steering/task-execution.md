# Task Execution Guidelines

## Autonomous Execution Philosophy

When executing tasks from a spec (especially when "run all tasks" is requested), work through tasks continuously without stopping for user confirmation unless absolutely necessary.

## When to Continue Without Prompting

**Always continue automatically for:**
- Successful task completion
- Writing tests that pass
- Creating new files or scripts
- Updating existing code
- Running verification scripts
- Minor issues that can be fixed immediately
- Expected warnings or non-critical errors
- Documentation updates (following documentation.md rules)

## When to Stop and Prompt User

**Only stop for critical blockers:**
- **Compilation errors** that prevent the project from running
- **Missing dependencies** that cannot be resolved automatically
- **Conflicting requirements** in the spec that need clarification
- **Data loss risk** (e.g., overwriting important files without clear instruction)
- **Architectural decisions** that significantly deviate from the spec
- **Test failures** that indicate fundamental design problems (not simple bugs)
- **External resource issues** (missing files, broken paths that can't be auto-fixed)

## Task Completion Flow

1. Read task from spec
2. Implement the task
3. Write/update tests
4. Run tests - if they fail, fix and retry
5. Verify implementation works
6. Mark task complete in tasks.md
7. **Immediately proceed to next task** (no summary, no prompt)

## Error Handling

### Minor Issues (Fix and Continue)
- Syntax errors → Fix immediately
- Type mismatches → Correct and continue
- Missing imports → Add and continue
- Simple logic bugs → Debug and fix
- Test failures from typos → Fix and rerun

### Critical Issues (Stop and Report)
- Cannot resolve dependency
- Spec is contradictory or unclear
- Breaking changes required
- External system unavailable

## Communication Style During Execution

- **Minimal output**: Brief status updates only
- **No summaries**: Unless explicitly requested
- **No "what's next" questions**: Just do the next task
- **No completion reports**: Mark task done and move on
- **Report only blockers**: If you must stop, explain why clearly

## Example Good Execution

```
Task 6.3.1: Implement crop sprite generation
✓ Created generate_crop_sprite() method
✓ Added tests - all passing
✓ Marked complete

Task 6.3.2: Integrate with Plot class
✓ Updated Plot._update_visual()
✓ Tests passing
✓ Marked complete

Task 6.3.3: Add growth stage visuals
✓ Implemented stage-based generation
✓ All tests passing
✓ Marked complete

All tasks in Phase 6.3 complete.
```

## Example Bad Execution (Avoid This)

```
Task 6.3.1: Implement crop sprite generation
✓ Created generate_crop_sprite() method
✓ Added tests - all passing

I've completed task 6.3.1. The implementation includes:
- New method in ProceduralArtGenerator
- Support for 4 growth stages
- Color-based variation
- Deterministic seeding
[10 more lines of summary]

Should I proceed to task 6.3.2? [WRONG - just do it]
```

## Multi-Task Execution

When given a spec with multiple tasks:
1. Start with first incomplete task
2. Complete it fully (code + tests)
3. Move immediately to next task
4. Repeat until all tasks done or critical blocker encountered
5. Report completion or blocker at the end

## Testing During Execution

- Run tests after implementation
- If tests fail, debug and fix immediately
- Don't ask permission to fix test failures
- Only stop if tests reveal fundamental design issues

## Verification Scripts

- Run verification scripts when they exist
- Fix any issues they reveal
- Don't stop to report verification results unless critical

## Summary at End (Optional)

Only at the very end of all tasks, provide a brief summary:
- "Completed tasks X.Y.Z through X.Y.W. All tests passing."
- That's it. No detailed breakdown unless requested.

## Override

User can always interrupt or ask for detailed explanations. This rule is about default autonomous behavior, not restricting user interaction.
