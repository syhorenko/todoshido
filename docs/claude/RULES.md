# Rules for Claude AI Interactions

Guidelines for how Claude should work with this codebase.

---

## Privacy & Security

### Private Chat Handling
If a chat session is marked with "private" remark, save with `-private` suffix.
- Regular: `sessions/<topic>/YYYY-MM-DD_description.md`
- Private: `sessions/<topic>/YYYY-MM-DD_description-private.md`

### Security Best Practices
1. Never commit secrets or credentials
2. Never log sensitive data
3. Sanitize examples with placeholder data
4. Review git diff before committing

---

## Documentation Requirements

### Chat History at Session End
Create session file in `docs/claude/sessions/<topic>/YYYY-MM-DD_description.md`

Required sections:
1. Session Summary (2-3 sentences)
2. Changes Made (files modified/created)
3. Key Decisions (choices and rationale)
4. Next Steps (for next session)
5. Commands Reference

---

## Code Quality Standards

### Before Writing Code
1. Read existing code first
2. Follow existing patterns (see `docs/claude/guides/`)
3. Check dependencies

### While Writing Code
1. Prefer editing over creating new files
2. Avoid over-engineering
3. Keep it simple
4. Use existing utilities
5. Follow Swift naming conventions
6. Use SwiftUI and SwiftData idioms

### After Writing Code
1. Build check (`⌘ + B` or `xcodebuild build`)
2. Format consistently
3. Security review
4. Test in preview and simulator
5. Remove compiler warnings

---

## SwiftUI/SwiftData Specific Rules

### SwiftData Models
1. Always use `@Model` macro
2. Use `final class` keyword
3. Provide explicit initializers
4. Register all models in Schema (in `ToDoApp.swift`)
5. Import both `Foundation` and `SwiftData`

### SwiftUI Views
1. Always provide `#Preview` for every view
2. Use `@Query` for data fetching
3. Use `@Environment(\.modelContext)` for CRUD operations
4. Wrap mutations in `withAnimation { }`
5. Import `SwiftUI` and `SwiftData` where needed

### Cross-Platform Code
1. Use `#if os(iOS)` and `#if os(macOS)` for platform-specific code
2. Test on both platforms if making cross-platform changes

---

## Git & Version Control

### Commit Guidelines
1. Only commit when user explicitly asks
2. Follow existing commit message style
3. Run git status, diff, log before committing
4. Include AI attribution footer

### Git Safety
- Never update git config
- Never run destructive commands without request
- Never skip hooks
- Never force push to main/master

---

## Communication Style

1. Professional objectivity
2. Concise responses
3. No unnecessary praise
4. Ask questions when unclear
5. Disagree when necessary

---

## Tool Usage

### Prefer Specialized Tools
- Read files instead of cat
- Edit files instead of sed/awk
- Glob for file search instead of find
- Grep for content search

### Use Bash Only For
- Git operations
- Build commands
- System commands

---

## Development Workflow

1. **Plan First** - For complex tasks, use plan mode
2. **Read Before Modify** - Always read files before editing
3. **Test Changes** - Build and preview before marking complete
4. **Document Decisions** - Update session files with important choices
5. **Update Context** - If architecture changes, update `CONTEXT.md`
