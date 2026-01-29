# Documentation Guidelines

## Documentation Philosophy

**Minimize documentation creation.** Only create documentation when explicitly requested or when it's essential for understanding complex systems.

## Documentation Organization

### Root Directory (Keep Minimal)

Only these core documentation files should remain in the root:

- `README.md` - Project overview and quick start
- `ARCHITECTURE.md` - System architecture and design decisions
- `CONTRIBUTING.md` - Development guidelines and coding standards
- `QUICKSTART.md` - Quick start guide for new developers

### KiroDocs Folder

All other documentation, summaries, and generated markdown files go in `KiroDocs/`:

- Task completion summaries (`TASK_*.md`)
- Testing guides
- Installation guides
- Setup verification documents
- Any other generated or temporary documentation

**Important**: The `KiroDocs/` folder is gitignored - these are working documents, not permanent project documentation.

## When to Create Documentation

### DO Create Documentation When:
- User explicitly requests it
- Implementing a complex system that needs explanation
- Creating a new major feature that requires a guide
- Writing API documentation for public interfaces

### DO NOT Create Documentation For:
- Task completion summaries (unless explicitly requested)
- Simple bug fixes or minor changes
- Routine implementation work
- Temporary notes or working documents

## Documentation Location Rules

1. **Core Project Docs**: Root directory (README, ARCHITECTURE, CONTRIBUTING, QUICKSTART)
2. **Spec Documents**: `.kiro/specs/` (requirements, design, tasks)
3. **Steering Rules**: `.kiro/steering/` (AI assistant guidance)
4. **Test Documentation**: `tests/README.md` and `tests/GDUNIT4_QUICK_REFERENCE.md`
5. **System-Specific Docs**: Within relevant directories (e.g., `scripts/farming/README.md`)
6. **Everything Else**: `KiroDocs/` (task summaries, guides, temporary docs)

## Summary Format

When a summary is needed, keep it minimal:

- 2-3 sentences maximum
- Focus on what was accomplished
- No bullet point lists unless essential
- No verbose recaps

## Example

**Good Summary:**
```
Implemented the farming grid system with plot management and crop growth. 
All tests passing. Ready for integration with the UI system.
```

**Avoid:**
```markdown
# Task 6.2.1 Completion Summary

## Overview
This task involved implementing the farming grid system...

## What Was Implemented
- FarmGrid class with grid management
- Plot class with state management
- Crop growth system
- Visual updates
- Signal system
...
[20 more lines]
```

## Updating This Rule

If documentation patterns change or new needs arise, update this steering file rather than creating ad-hoc documentation.
