# Claude AI Instructions for ToDo iOS App

---

## BEFORE RESPONDING CHECKLIST

**STOP! Before sending ANY response after completing work, verify:**

- [ ] Did I modify 3+ files? → **CREATE SESSION SUMMARY NOW**
- [ ] Is the task complete? → **CREATE SESSION SUMMARY NOW**
- [ ] Did user correct me? → **UPDATE `tasks/lessons.md` NOW**
- [ ] Did I add SwiftData model fields? → **Document pattern in lessons**

**Session summary location:** `docs/claude/sessions/<topic>/YYYY-MM-DD_description.md`

**DO NOT skip this checklist. This is the #1 recurring mistake.**

---

## Session Start Workflow

**MANDATORY: At the start of EVERY new conversation:**

1. **Review Core Documentation** (read these files):
   - `docs/claude/CONTEXT.md` - Project context, architecture, tech stack
   - `docs/claude/RULES.md` - Behavioral guidelines, code quality standards
   - `tasks/lessons.md` - Learn from past mistakes and patterns

2. **Check for Active Work**:
   - Review `docs/claude/FUTURE_PLANS.md` for roadmap items
   - Check `docs/claude/migrations/` for ongoing large refactorings

## Session History (On-Demand)

**DO NOT read session files automatically at start.** Only read previous sessions when:

1. **User specifies a feature/topic** - When the user says they're working on a specific feature (e.g., "I'm working on the Tickets module"), check if `docs/claude/sessions/<feature>/` exists and read relevant sessions
2. **User explicitly asks** - When the user requests context from previous sessions
3. **Continuing previous work** - When the user mentions continuing or resuming previous work

---

## Development Guides (On-Demand)

**DO NOT load these guides automatically.** Load based on task keywords:

| When user mentions... | Load this guide |
|----------------------|-----------------|
| View, SwiftUI, screen, UI, navigation | `docs/claude/guides/swiftui-views.md` |
| Model, data, SwiftData, persistence, query | `docs/claude/guides/swiftdata-models.md` |
| New module, create feature, checklist | `docs/claude/guides/module-checklist.md` |

**When creating a new module/feature**, load `docs/claude/guides/module-checklist.md` first.

---

## Workflow Orchestration

### 1. Plan Mode Default

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop

- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
- Build command: `xcodebuild -project ToDo.xcodeproj -scheme ToDo build`

### 5. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

---

## Session End Workflow

**MANDATORY: At the end of EVERY significant session:**

1. **Create Session Summary** in `docs/claude/sessions/<topic>/YYYY-MM-DD_description.md`
   - **Format:** Sessions organized by topic folders, then date and description
   - **Privacy Rule:** If session is marked "private", use `-private` suffix (gitignored)
   - **Required Sections:**
     - Session Summary (2-3 sentences)
     - Changes Made (files modified/created)
     - Key Decisions (important choices and rationale)
     - Next Steps (what to do next session)
     - Commands Reference

2. **Update Documentation** (if applicable):
   - Update `docs/claude/CONTEXT.md` if architecture changed
   - Update `docs/claude/FUTURE_PLANS.md` if roadmap items completed

3. **Capture Lessons**:
   - Update `tasks/lessons.md` if there were corrections

---

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

---

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

---

## Project Quick Reference

### Technology Stack
- **Language:** Swift
- **Framework:** SwiftUI + SwiftData
- **Build System:** Xcode
- **Platforms:** iOS, macOS (cross-platform)

### Key Patterns
- **Declarative UI:** SwiftUI views with `body` property
- **Reactive Data:** `@Query` for automatic UI updates
- **Data Persistence:** SwiftData with `@Model` macro
- **Cross-Platform:** Conditional compilation with `#if os(iOS)` / `#if os(macOS)`

### Critical Rules
- Always use `@Model` macro for data models
- Register all models in Schema (in `ToDoApp.swift`)
- Wrap mutations in `withAnimation { }`
- Use `@Query` for data fetching, not manual fetches
- Provide `#Preview` for every custom view
- Use `final class` for SwiftData models
- Import both `SwiftUI` and `SwiftData` where needed

---

## Documentation System

```
docs/claude/
├── CONTEXT.md          # Project architecture (read at start)
├── RULES.md            # Behavioral guidelines (read at start)
├── FUTURE_PLANS.md     # Roadmap items
├── guides/             # Development guides (load on-demand)
│   ├── swiftui-views.md
│   ├── swiftdata-models.md
│   └── module-checklist.md
├── sessions/           # Chat history by topic (load on-demand)
└── migrations/         # Large refactoring guides
```

**For complete guidelines, see:** `docs/claude/RULES.md`

---

**Version:** 1.0  
**Last Updated:** 2026-04-15
