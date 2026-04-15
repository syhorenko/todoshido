# Claude AI Documentation

This folder contains documentation and context for AI-assisted development with Claude.

## Folder Structure

```
docs/claude/
├── README.md           # This file
├── RULES.md            # Guidelines for Claude interactions
├── CONTEXT.md          # Project context and architecture
├── FUTURE_PLANS.md     # Roadmap and TODOs
├── guides/             # Development guides (loaded on-demand)
│   ├── swiftui-views.md
│   ├── swiftdata-models.md
│   └── module-checklist.md
├── sessions/           # Chat history by topic
│   ├── setup/          # Setup sessions
│   ├── general/        # Misc sessions
│   └── <topic>/        # Feature-specific folders
└── migrations/         # Migration guides
```

## Purpose

- **Continuity**: Resume work where you left off
- **Knowledge Transfer**: Share context with future sessions
- **Decision Tracking**: Record architectural choices
- **Accountability**: Track AI-assisted changes

## Privacy

Files with `-private` suffix are gitignored:
- `sessions/**/*-private.md`

## Quick Start

**Starting a session:**
1. Review `CONTEXT.md` for project overview
2. Check `RULES.md` for guidelines
3. Look at recent `sessions/` files

**Ending a session:**
1. Create session summary in `sessions/<topic>/`
2. Update docs if major changes made
