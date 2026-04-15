# Claude Documentation Setup Instructions

**Purpose:** Instructions for Claude to set up the documentation structure in any project.

**Location:** Place this file in the **project root directory**.

**Usage:** Copy this file to your project root and tell Claude: "Set up Claude documentation using SETUP_INSTRUCTIONS.md"

---

## Instructions for Claude

When the user asks you to set up Claude documentation using this file, follow these steps:

### Step 1: Create Folder Structure

**Use the Write tool or Bash mkdir to create these directories from the project root:**

Create a placeholder file in each directory to ensure the folder structure exists:

1. Create `docs/claude/sessions/setup/.gitkeep` (empty file)
2. Create `docs/claude/sessions/general/.gitkeep` (empty file)
3. Create `docs/claude/migrations/.gitkeep` (empty file)
4. Create `docs/claude/guides/.gitkeep` (empty file) - for on-demand development guides

This creates the following structure:
```
docs/
└── claude/
    ├── guides/         # Development guides (loaded on-demand)
    ├── sessions/
    │   ├── setup/
    │   └── general/
    └── migrations/
```

**How to create folders with Claude tools:**
- Use the Write tool to create a file like `docs/claude/sessions/setup/.gitkeep` with empty content
- This automatically creates all parent directories

### Step 2: Update .gitignore

Add these lines to `.gitignore` (create if doesn't exist):
```
# Claude AI Documentation - Private Sessions
# Sessions marked as 'private' are excluded from version control
docs/claude/sessions/*-private.md
docs/claude/sessions/**/*-private.md
```

### Step 3: Gather Project Information

Ask the user for:
1. **Project Name** - Name of the project
2. **Project Description** - Brief description of what the project does
3. **Primary Language** - e.g., Kotlin, Swift, Python, JavaScript
4. **Framework** - e.g., Android, iOS, Django, React
5. **Build Command** - e.g., `./gradlew build`, `xcodebuild`, `npm run build`
6. **Test Command** - e.g., `./gradlew test`, `npm test`

### Step 4: Analyze Project Structure

Scan the project to detect:

#### 4.1 Build System Detection
- Check for `build.gradle` or `build.gradle.kts` → Gradle
- Check for `package.json` → npm/Node.js
- Check for `Podfile` or `*.xcodeproj` → iOS/Xcode
- Check for `pubspec.yaml` → Flutter
- Check for `Cargo.toml` → Rust
- Check for `pom.xml` → Maven

#### 4.2 Platform Detection
- Gradle + AndroidManifest.xml → Android
- *.xcodeproj or *.xcworkspace → iOS
- package.json + react-native → React Native
- pubspec.yaml → Flutter

#### 4.3 Source File Analysis

**IMPORTANT: Exclude third-party directories from all scans:**
- `Pods/`, `Carthage/`, `DerivedData/`, `Frameworks/` (iOS)
- `.gradle/`, `build/`, `generated/` (Android)
- `node_modules/`, `bower_components/` (JavaScript)
- `third_party/`, `third-party/`, `external/`, `vendor/`, `libs/`

**Count source files by type:**
- `*.kt` - Kotlin files
- `*.java` - Java files
- `*.swift` - Swift files
- `*.m`, `*.mm`, `*.h` - Objective-C files
- `*.dart` - Dart/Flutter files
- `*.tsx`, `*.jsx` - React/React Native files

#### 4.4 UI Framework Detection

**Android:**
- Search for `@Composable` in *.kt → Jetpack Compose
- Count XML files in `res/layout*` → XML Layouts
- Search for `WebView`, `loadUrl`, `addJavascriptInterface` → WebView Hybrid
- Search for `@JavascriptInterface` → JavaScript Bridge

**iOS:**
- Search for `SwiftUI`, `@State`, `@Binding` in *.swift → SwiftUI
- Search for `UIViewController`, `UIView`, `UIKit` → UIKit
- Count `*.storyboard` and `*.xib` files

**Flutter:**
- Search for `StatelessWidget`, `StatefulWidget` in *.dart

**React Native:**
- Count *.tsx and *.jsx files
- Check package.json for navigation/state libraries

#### 4.5 Screen/View Scanning

**Android - Scan Activities:**
Find files matching `*Activity.kt` or `*Activity.java` (excluding test directories).
For each, check content to determine UI approach:
- Contains `setContentView` or `R.layout` → XML
- Contains `setContent` or `ComposeView` → Compose
- Contains `WebView` or `loadUrl` → WebView

**Android - Scan Fragments:**
Find files matching `*Fragment.kt` or `*Fragment.java`.
Check content for:
- `onCreateView` or `inflater.inflate` → XML
- `ComposeView` or `setContent` → Compose
- `DialogFragment` or `BottomSheetDialogFragment` → Dialog

**iOS - Scan ViewControllers:**
Find files matching `*ViewController.swift` or `*ViewController.m`.
Check content for:
- `UITableViewController` or `UICollectionViewController` → TableView/Collection
- `UINavigationController` → Navigation
- `UITabBarController` → TabBar

**iOS - Scan SwiftUI Views:**
Find files matching `*View.swift` (excluding ViewControllers).

**iOS - Scan Cells:**
Find files matching `*Cell.swift` or `*Cell.m`.

#### 4.6 Architecture Pattern Detection

Search for directory names and file patterns:
- `*ViewModel*` files/dirs → MVVM
- `*Presenter*` files/dirs → MVP
- `*Strategy*` files/dirs → Strategy Pattern
- `*Manager*` files/dirs → Manager Pattern
- `*Repository*` files/dirs → Repository Pattern
- `*Bridge*` or `*JSInterface*` files → Bridge Pattern
- `*UseCase*` files or `domain/` dir → Clean Architecture

#### 4.7 Dependency Detection (Android/Gradle)

Check `build.gradle` or `app/build.gradle` for:
- `retrofit` → Retrofit
- `room` → Room
- `hilt` → Hilt
- `dagger` → Dagger
- `koin` → Koin
- `coroutines` → Coroutines
- `timber` → Timber
- `firebase` → Firebase
- `zettle` or `izettle` → Zettle SDK
- `navigation` → Navigation Component

### Step 5: Extract Code Patterns & Generate Development Guides

**This step analyzes actual code in the project to extract patterns and create MODULAR guide files in `docs/claude/guides/`.**

**IMPORTANT: Do NOT embed development guides in CLAUDE.md.** Instead, create separate guide files that are loaded on-demand based on task keywords. This keeps the main CLAUDE.md file small (~150 lines) and only loads relevant guides when needed.

The goal is to create focused development guides with real code snippets that show how to build new features following the project's established patterns.

#### 5.1 Identify Representative Files

For each major component type, find 2-3 well-structured examples:

**iOS/Objective-C:**
- Find a well-structured `*ViewController.m` (look for ones with tableView methods, configureUI, configureStyles)
- Find a well-structured `*TableViewCell.m` or `*CollectionViewCell.m`
- Find a model class `*Model.m` that loads from JSON or has computed properties
- Find a delegate protocol definition

**iOS/Swift:**
- Find a `*ViewController.swift` with modern patterns
- Find a `*View.swift` for SwiftUI patterns if used
- Find model/service classes

**Android/Kotlin:**
- Find a well-structured `*Activity.kt` or `*Fragment.kt`
- Find an adapter class `*Adapter.kt`
- Find a ViewModel `*ViewModel.kt`
- Find a Repository `*Repository.kt`

**React/TypeScript:**
- Find a well-structured component `*.tsx`
- Find a hook `use*.ts`
- Find a context/store file

#### 5.2 Extract Patterns from Code

For each file type found, read the actual code and extract:

1. **File Header Pattern** - How files start (imports, copyright, module comments)
2. **Class Structure** - How classes are organized (MARK comments, regions, method grouping)
3. **Naming Conventions** - Prefix/suffix patterns (e.g., APM*, *ViewController, *Model)
4. **Common Methods** - Lifecycle methods, configuration methods, delegate implementations
5. **Styling Patterns** - How styling is applied (dyeStyleName, themes, etc.)
6. **Localization Patterns** - How strings are localized (Dialect, NSLocalizedString, etc.)
7. **Data Loading** - How data is loaded from JSON, API, or other sources
8. **Delegate/Protocol Patterns** - How communication between components works
9. **Error Handling** - Common error handling patterns
10. **Accessibility** - How accessibility is configured

#### 5.3 Generate Code Templates

Based on extracted patterns, create template examples for CLAUDE.md:

**For iOS Projects, generate sections for:**
1. Creating View Controllers (header + implementation patterns)
2. Creating Table/Collection View Cells
3. Creating Data Models
4. Style System usage
5. Localization usage
6. XIB/Storyboard patterns
7. Compile-time feature flags (if detected)
8. NSUserDefaults patterns
9. Notification patterns
10. Delegate patterns
11. Accessibility patterns

**For Android Projects, generate sections for:**
1. Creating Activities/Fragments
2. Creating RecyclerView Adapters
3. Creating ViewModels
4. Creating Repositories
5. Dependency Injection setup
6. Navigation patterns
7. Resource/Theme usage
8. Data binding patterns

**For React/TypeScript Projects, generate sections for:**
1. Creating Components
2. Creating Custom Hooks
3. State Management patterns
4. API Integration patterns
5. Styling patterns
6. Testing patterns

#### 5.4 Pattern Extraction Strategy

**Step-by-step approach:**

1. **Find base classes:**
   ```
   # iOS
   grep -r "class.*ViewController" --include="*.h" | head -5
   grep -r "@interface.*TableViewCell" --include="*.h" | head -5

   # Android
   grep -r "class.*Activity.*:" --include="*.kt" | head -5
   grep -r "class.*Fragment.*:" --include="*.kt" | head -5
   ```

2. **Read a representative file completely** - Pick the most complete, well-documented example

3. **Extract the structure:**
   - Header comment style
   - Import organization
   - Class organization (properties, lifecycle, configuration, data, delegate methods)
   - MARK/PRAGMA comments or region dividers

4. **Generalize the pattern:**
   - Replace specific names with `[FeatureName]` or `Feature` placeholder
   - Keep the structure and method signatures
   - Include comments explaining what each section does

5. **Verify pattern is consistent:**
   - Check 2-3 other files to confirm the pattern is used consistently
   - Note any variations

#### 5.5 Create Modular Guide Files

**Create separate guide files in `docs/claude/guides/` for each topic.**

Each guide file should be self-contained and focused on one topic.

**For iOS/Objective-C projects, create these files:**
- `docs/claude/guides/ui-viewcontrollers.md` - ViewController patterns
- `docs/claude/guides/ui-cells.md` - TableViewCell/CollectionViewCell patterns
- `docs/claude/guides/data-models.md` - Model patterns, JSON loading, NSUserDefaults
- `docs/claude/guides/styling.md` - Style system (Dye or equivalent)
- `docs/claude/guides/localization.md` - Localization (Dialect or NSLocalizedString)
- `docs/claude/guides/accessibility.md` - Accessibility patterns
- `docs/claude/guides/module-checklist.md` - Quick reference checklist for new modules

**For Android projects, create these files:**
- `docs/claude/guides/ui-activities.md` - Activity patterns
- `docs/claude/guides/ui-fragments.md` - Fragment patterns
- `docs/claude/guides/ui-adapters.md` - RecyclerView adapter patterns
- `docs/claude/guides/viewmodels.md` - ViewModel patterns
- `docs/claude/guides/repositories.md` - Repository patterns
- `docs/claude/guides/navigation.md` - Navigation patterns
- `docs/claude/guides/module-checklist.md` - Quick reference checklist

**For React/TypeScript projects, create these files:**
- `docs/claude/guides/components.md` - Component patterns
- `docs/claude/guides/hooks.md` - Custom hook patterns
- `docs/claude/guides/state-management.md` - State management patterns
- `docs/claude/guides/api-integration.md` - API integration patterns
- `docs/claude/guides/module-checklist.md` - Quick reference checklist

#### 5.6 Guide File Format

Each guide file should follow this format:

```markdown
# [Topic Name]

This guide covers [topic] patterns used in the [Project Name] codebase.

## Overview

Brief description and key concepts.

## [Pattern 1]

### Example Code

\`\`\`[language]
// Extracted from actual codebase
[CODE HERE]
\`\`\`

## [Pattern 2]

...

## Key Points

- Point 1 about this pattern
- Point 2 about this pattern
- Common mistakes to avoid
```

#### 5.7 Add Keyword Triggers to CLAUDE.md

In CLAUDE.md, add a table that maps keywords to guide files:

```markdown
## Development Guides (On-Demand)

**DO NOT load these guides automatically.** Load based on task keywords:

| When user mentions... | Load this guide |
|----------------------|-----------------|
| ViewController, screen | `docs/claude/guides/ui-viewcontrollers.md` |
| Cell, TableViewCell, XIB | `docs/claude/guides/ui-cells.md` |
| Model, JSON, data | `docs/claude/guides/data-models.md` |
| Style, theme, color | `docs/claude/guides/styling.md` |
| Localization, translation | `docs/claude/guides/localization.md` |
| Accessibility, VoiceOver | `docs/claude/guides/accessibility.md` |
| New module, create feature | `docs/claude/guides/module-checklist.md` |
```

#### 5.8 Quality Checks for Guide Files

Before finalizing guide files:

- [ ] Code compiles (no syntax errors)
- [ ] Placeholder names are consistent (`Feature`, `APMFeature`, etc.)
- [ ] Comments explain the purpose, not the obvious
- [ ] Code follows the project's actual style (not generic examples)
- [ ] All imports shown are real imports from the project
- [ ] Base classes mentioned actually exist in the project

### Step 6: Create Documentation Files

Create these files with the gathered information:

#### 6.1 Create `docs/claude/README.md`

```markdown
# Claude AI Documentation

This folder contains documentation and context for AI-assisted development with Claude.

## Folder Structure

docs/claude/
├── README.md           # This file
├── RULES.md            # Guidelines for Claude interactions
├── CONTEXT.md          # Project context and architecture
├── FUTURE_PLANS.md     # Roadmap and TODOs
├── sessions/           # Chat history by topic
│   ├── setup/          # Setup sessions
│   ├── general/        # Misc sessions
│   └── <topic>/        # Feature-specific folders
└── migrations/         # Migration guides

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
```

#### 6.2 Create `docs/claude/CONTEXT.md`

Use the CONTEXT.md Template below, filling in:
- Project name and description (from user input)
- Technology stack (language, framework, build system)
- Auto-detected architecture patterns
- Auto-detected UI framework and approach
- List of screens/activities/viewcontrollers found
- Key dependencies
- File statistics
- Reference commands (build, test)

#### 6.3 Create `docs/claude/RULES.md`

Use the RULES.md Template below.

#### 6.4 Create `docs/claude/FUTURE_PLANS.md`

Use the FUTURE_PLANS.md Template below.

#### 6.5 Create `CLAUDE.md` in Project Root

Use the CLAUDE.md Template below, filling in:
- Project-specific information and auto-detected structure
- **Development Guide section** with extracted code patterns (from Step 5)

The CLAUDE.md file should contain BOTH:
1. Session workflow instructions (template provided)
2. Development Guide with code examples (generated from Step 5 analysis)

### Step 7: Create Initial Session File

Create `docs/claude/sessions/setup/YYYY-MM-DD_initial-setup.md` with:
- Session summary
- List of files created
- Next steps

### Step 8: Report Results

After setup, report to the user:
1. Files created
2. Detected project information:
   - Platform and build system
   - UI framework
   - Number of screens/activities/viewcontrollers
   - Architecture patterns
   - Key dependencies
   - File counts by language
3. Code patterns extracted (list the sections added to CLAUDE.md)
4. Next steps for the user

### Step 9: Cleanup

After successful setup:
1. Ask the user if they want to delete `SETUP_INSTRUCTIONS.md` from the project root
2. If yes, delete it (it's no longer needed after setup is complete)
3. The setup instructions can be kept in version control separately if needed for other projects

---

## File Templates

### RULES.md Template

```markdown
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
2. Follow existing patterns
3. Check dependencies

### While Writing Code
1. Prefer editing over creating new files
2. Avoid over-engineering
3. Keep it simple
4. Use existing utilities

### After Writing Code
1. Compile check
2. Format consistently
3. Security review

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
```

### CONTEXT.md Template

```markdown
# Project Context

Essential knowledge about [PROJECT_NAME].

---

## Project Overview

**Name:** [PROJECT_NAME]
**Purpose:** [PROJECT_DESCRIPTION]
**Primary Language:** [PRIMARY_LANGUAGE]
**Framework:** [FRAMEWORK]

---

## Technology Stack

### Core Technologies
- **Language:** [PRIMARY_LANGUAGE]
- **Framework:** [FRAMEWORK]
- **Build System:** [BUILD_SYSTEM]

### Key Dependencies
[LIST_DETECTED_DEPENDENCIES]

---

## Architecture

### Patterns Used
[LIST_DETECTED_ARCHITECTURE_PATTERNS]

### UI Framework
- **Framework:** [DETECTED_UI_FRAMEWORK]
- **UI Approach:** [UI_DETAILS]

---

## Project Structure

### Modules
[LIST_DETECTED_MODULES]

### Package/Feature Organization
[PACKAGE_STRUCTURE]

---

## Screens/Views

### Activities (Android)
[LIST_ACTIVITIES_WITH_UI_TYPE]

### Fragments (Android)
[LIST_FRAGMENTS_WITH_UI_TYPE]

### ViewControllers (iOS)
[LIST_VIEWCONTROLLERS]

### SwiftUI Views (iOS)
[LIST_SWIFTUI_VIEWS]

---

## File Statistics

- **Kotlin files:** [COUNT]
- **Java files:** [COUNT]
- **Swift files:** [COUNT]
- **Objective-C files:** [COUNT]
- **XML resources:** [COUNT]

---

## Reference Commands

```bash
# Build
[BUILD_COMMAND]

# Test
[TEST_COMMAND]

# Clean build
[CLEAN_BUILD_COMMAND]
```

---

## Key Entry Points

[DESCRIBE_MAIN_ENTRY_POINTS]

---

**Last Updated:** [DATE]
```

### FUTURE_PLANS.md Template

```markdown
# Future Plans & Roadmap

Track upcoming work, ideas, and technical debt for [PROJECT_NAME].

---

## In Progress

*Currently being worked on*

| Task | Status | Owner | Notes |
|------|--------|-------|-------|
| - | - | - | - |

---

## Planned Work

### High Priority
- [ ] Item 1
- [ ] Item 2

### Medium Priority
- [ ] Item 1
- [ ] Item 2

### Low Priority
- [ ] Item 1
- [ ] Item 2

---

## Feature Ideas

*Ideas to explore in the future*

- Idea 1
- Idea 2

---

## Technical Debt

*Code improvements and refactoring needed*

- [ ] Debt item 1
- [ ] Debt item 2

---

## Quarterly Goals

### Q1 [YEAR]
- [ ] Goal 1
- [ ] Goal 2

### Q2 [YEAR]
- [ ] Goal 1
- [ ] Goal 2

---

## Completed

*Recently completed items (move here from above)*

- [x] Initial Claude documentation setup - [DATE]

---

**Last Updated:** [DATE]
```

### CLAUDE.md Template

```markdown
# Claude AI Instructions for [PROJECT_NAME]

## Session Start Workflow

**MANDATORY: At the start of EVERY new conversation:**

1. **Review Core Documentation** (read these files):
   - `docs/claude/CONTEXT.md` - Project context, architecture, tech stack, key decisions
   - `docs/claude/RULES.md` - Behavioral guidelines, code quality standards, git safety
   - `tasks/lessons.md` - Learn from past mistakes and patterns

2. **Check for Active Work**:
   - Review `docs/claude/FUTURE_PLANS.md` for roadmap items
   - Check `docs/claude/migrations/` for ongoing large refactorings

## Session History (On-Demand)

**DO NOT read session files automatically at start.** Only read previous sessions when:

1. **User specifies a feature/topic** - When the user says they're working on a specific feature (e.g., "I'm working on the auth module"), check if `docs/claude/sessions/<feature>/` exists and read relevant sessions
2. **User explicitly asks** - When the user requests context from previous sessions
3. **Continuing previous work** - When the user mentions continuing or resuming previous work

---

## Development Guides (On-Demand)

**DO NOT load these guides automatically.** Load based on task keywords:

| When user mentions... | Load this guide |
|----------------------|-----------------|
| [KEYWORD_1] | `docs/claude/guides/[GUIDE_1].md` |
| [KEYWORD_2] | `docs/claude/guides/[GUIDE_2].md` |
| [KEYWORD_3] | `docs/claude/guides/[GUIDE_3].md` |
| New module, create feature | `docs/claude/guides/module-checklist.md` |

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
- Run build/compile command to verify: `[BUILD_COMMAND]`

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
   - **Topic Folders:** Group related sessions (e.g., `feature-name/`, `bugfixes/`, `setup/`, `general/`)
   - **Privacy Rule:** If session is marked "private", use `-private` suffix (gitignored)
   - **Required Sections:**
     - Session Summary (2-3 sentences of what was accomplished)
     - Changes Made (list of files modified/created)
     - Key Decisions (important choices and rationale)
     - Next Steps (what to do in the next session)
     - Commands Reference (important commands used)

2. **Update Documentation** (if applicable):
   - Update `docs/claude/CONTEXT.md` if architecture changed
   - Update `docs/claude/FUTURE_PLANS.md` if roadmap items completed
   - Update migration guides if working on large refactoring

3. **Capture Lessons**:
   - Update `tasks/lessons.md` if there were corrections

### Session File Privacy

**Critical Rule:**
- Regular session: `docs/claude/sessions/<topic>/YYYY-MM-DD_description.md`
- Private session: `docs/claude/sessions/<topic>/YYYY-MM-DD_description-private.md` (gitignored)

**Use private sessions for:**
- Discussions involving sensitive business logic
- Debugging with real customer data
- Security vulnerability analysis
- Personal development notes not ready for team review

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

## Project-Specific Rules

### Before Writing Code

1. **Read existing code first** - Never propose changes without reading the file
2. **Understand patterns** - Follow existing code style and architecture (see `docs/claude/CONTEXT.md`)
3. **Check dependencies** - Verify SDK versions and compatibility

### Technology Stack

- **Language:** [PRIMARY_LANGUAGE]
- **Framework:** [FRAMEWORK]
- **Build System:** [BUILD_SYSTEM]
- **Architecture:** [DETECTED_ARCHITECTURE]
- **Key Patterns:** [DETECTED_PATTERNS]

### Code Quality Standards

1. **Compile check:** Run `[BUILD_COMMAND]`
2. **Format consistently:** Follow [LANGUAGE] conventions
3. **Add documentation only for public APIs:** Don't over-comment internal code
4. **Security review:** Check for OWASP top 10 vulnerabilities

### Testing Requirements

- **Code must compile** - No exceptions
- **Run relevant tests** - If tests exist for the area
- **Never mark task as completed** if tests fail
- **Create new task** describing what needs fixing if blocked

---

## Git & Version Control

### Commit Guidelines

1. **Only commit when user explicitly asks**
2. **Follow existing commit message style** (check `git log` first)
3. **Run git status, diff, and log** before committing
4. **Always use heredoc** for multi-line commit messages
5. **Include AI attribution** footer:
   ```
   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

### Git Safety

- **Never** update git config
- **Never** run destructive commands without explicit user request
- **Never** skip hooks (`--no-verify`, `--no-gpg-sign`)
- **Never** force push to main/master (warn user if they request it)
- **Avoid** `git commit --amend` (only when safe and explicit)

### Pull Request Guidelines

1. **Analyze ALL commits** in the PR, not just the latest
2. **Draft clear PR description** with summary and test plan
3. **Use heredoc** for PR body formatting
4. **Include AI attribution** footer
5. **Return PR URL** when done

---

## Tool Usage Guidelines

### Prefer Specialized Tools

- **Read** files instead of `cat`
- **Edit** files instead of `sed/awk`
- **Write** files instead of `echo >` or `cat <<EOF`
- **Glob** for file search instead of `find`
- **Grep** for content search instead of `grep/rg`

### Use Bash Only For

- Git operations
- Build commands
- System commands requiring shell execution
- Installing dependencies

### Parallel Tool Calls

- **Do use parallel calls** when operations are independent
- **Don't use parallel calls** when one depends on another
- **Single message, multiple tools** for true parallelism

### Task Tool (Agents)

- **Use Explore agent** for open-ended codebase searches
- **Don't use Task** for simple file reads or specific class lookups
- **Always provide clear prompts** with expected outcomes

---

## Communication Style

### Tone

1. **Professional objectivity** - Prioritize accuracy over validation
2. **Concise responses** - This is a CLI tool, keep it brief
3. **No unnecessary praise** - Avoid "You're absolutely right!"
4. **Ask questions** when requirements are unclear
5. **Disagree when necessary** - Technical accuracy matters most

### Formatting

1. **Use markdown** - GitHub-flavored markdown for formatting
2. **No emojis** - Unless user explicitly requests them
3. **File references** - Include path and line numbers (e.g., `file.kt:256`)
4. **Code blocks** - Always specify language for syntax highlighting

### Never Do This

- Use echo/printf to communicate with user
- Use code comments to explain to user
- Output text via Bash commands
- Use output text directly in response instead

---

## Reference Commands

```bash
# Build
[BUILD_COMMAND]

# Test
[TEST_COMMAND]

# Clean build
[CLEAN_BUILD_COMMAND]

# Git operations (review first)
git status
git diff
git log --oneline -10
```

---

## Quick Reference: File Locations

See `docs/claude/CONTEXT.md` for complete architecture overview.

### Key Entry Points
[LIST_KEY_ENTRY_POINTS]

### Project Structure
[INSERT_DETECTED_PROJECT_STRUCTURE]

---

## Documentation System

```
docs/claude/
├── CONTEXT.md          # Project architecture (read at start)
├── RULES.md            # Behavioral guidelines (read at start)
├── FUTURE_PLANS.md     # Roadmap items
├── guides/             # Development guides (load on-demand)
│   ├── [guide-1].md
│   ├── [guide-2].md
│   └── module-checklist.md
├── sessions/           # Chat history by topic (load on-demand)
└── migrations/         # Large refactoring guides
```

**For complete guidelines, see:** `docs/claude/RULES.md`

---

## Project Quick Reference

### Technology Stack
- **Language:** [PRIMARY_LANGUAGE]
- **Framework:** [FRAMEWORK]
- **Build System:** [BUILD_SYSTEM]

### Key Patterns
[INSERT_KEY_PATTERNS]

### Critical Rules
[INSERT_CRITICAL_RULES]

---

**Version:** 1.0
**Last Updated:** [DATE]

**Note:** Development guides are in `docs/claude/guides/` and loaded on-demand based on task keywords. This keeps the main CLAUDE.md file small.
```

### Initial Session File Template

Create this in `docs/claude/sessions/setup/YYYY-MM-DD_initial-setup.md`:

```markdown
# Initial Setup Session

**Date:** [DATE]
**Duration:** ~[X] minutes
**Topic:** Project setup for Claude AI documentation

---

## Session Summary

Set up Claude AI documentation structure for [PROJECT_NAME]. Created folder structure, configuration files, and analyzed project to document architecture and patterns.

---

## Changes Made

### Files Created
- `docs/claude/README.md` - Documentation overview
- `docs/claude/CONTEXT.md` - Project context and architecture
- `docs/claude/RULES.md` - Guidelines for Claude interactions
- `docs/claude/FUTURE_PLANS.md` - Roadmap template
- `docs/claude/sessions/setup/.gitkeep` - Folder placeholder
- `docs/claude/sessions/general/.gitkeep` - Folder placeholder
- `docs/claude/migrations/.gitkeep` - Folder placeholder
- `CLAUDE.md` - Main instructions file (project root)

### Configuration Changes
- Updated `.gitignore` with private session rules

---

## Project Analysis Results

### Platform & Build
- **Platform:** [DETECTED_PLATFORM]
- **Build System:** [DETECTED_BUILD_SYSTEM]

### UI Framework
- **Framework:** [DETECTED_UI_FRAMEWORK]
- **Activities:** [COUNT]
- **Fragments:** [COUNT]

### Architecture
- **Patterns:** [DETECTED_PATTERNS]

### Dependencies
[LIST_KEY_DEPENDENCIES]

### File Statistics
- Kotlin: [COUNT]
- Java: [COUNT]
- XML: [COUNT]

---

## Next Steps

1. Review generated documentation files
2. Customize `FUTURE_PLANS.md` with actual roadmap items
3. Add project-specific rules to `RULES.md` if needed
4. Start using session files to track AI-assisted work

---

## Commands Used

```bash
# Verification
ls -la docs/claude/
cat CLAUDE.md
```

---

**Session Type:** Setup
**Privacy:** Public
```

---

## Notes for Claude

1. **File is in project root** - This file should be in the project root directory
2. **Create folders using Write tool** - Use Write tool to create `.gitkeep` files which auto-creates parent folders
3. **Be thorough** - Scan all relevant directories
4. **Exclude third-party** - Always exclude Pods, node_modules, build, etc.
5. **Show progress** - Tell user what you're scanning
6. **Report findings** - Summarize what was detected
7. **Ask when unclear** - If project type is ambiguous, ask user
8. **Use TodoWrite** - Track setup steps as todos
9. **Verify structure** - After creating files, use Glob to verify they exist
10. **Extract real code patterns** - Step 5 is critical: read actual source files and extract patterns to generate the Development Guide section of CLAUDE.md
11. **Code examples must be real** - Don't use generic examples; extract from actual project files
12. **Find the best examples** - Look for well-structured files with good comments and clear organization
13. **Generalize but keep structure** - Replace specific feature names with placeholders but keep method signatures, imports, and structure
14. **Ask about cleanup** - After setup is complete, ask if user wants to delete SETUP_INSTRUCTIONS.md from project root

---

## Example: iOS/Objective-C Development Guide Output

Below is an example of what the Development Guide section should look like for an iOS/Objective-C project. Claude should extract actual patterns from the codebase and generate similar sections.

```markdown
# [ProjectName] - Development Guide

This guide contains patterns and conventions used in the framework for creating new features.

## Project Structure

\`\`\`
ProjectName/
├── General/
│   └── StyleNames.h          # Style name constants
├── Modules/
│   └── [ModuleName]/
│       ├── [SubFeature]/
│       │   ├── *.storyboard     # View controller storyboards
│       │   ├── *.h / *.m        # View controllers
│       │   └── Cells/           # Table/Collection view cells
│       │       ├── *.h / *.m    # Cell classes
│       │       └── *.xib        # Cell layouts
│       ├── Models/              # Data models
│       │   ├── *.h / *.m
│       └── Resources/           # JSON configs, assets
│           └── *.json
\`\`\`

---

## 1. Creating View Controllers

### Base Classes

- **[BaseListViewController]** - For table view based screens
- **[BaseViewController]** - Base view controller

### Header File Pattern (.h)

\`\`\`objc
//
//  [Prefix]FeatureViewController.h
//  [ProjectName]
//

#import "[BaseViewController].h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - [Prefix]FeatureViewController Interface -

@interface [Prefix]FeatureViewController : [BaseListViewController]

// MARK: IBOutlet Properties

@property (nonatomic, weak, readwrite, nullable) IBOutlet UIView *navigationBarView;
@property (nonatomic, weak, readwrite, nullable) IBOutlet UIButton *confirmButton;

// MARK: Properties

@property (nonatomic, assign) BOOL partOfAppNavigation;

@end

NS_ASSUME_NONNULL_END
\`\`\`

### Implementation File Pattern (.m)

\`\`\`objc
//
//  [Prefix]FeatureViewController.m
//  [ProjectName]
//

#import "[Prefix]FeatureViewController.h"

#import "[Prefix]FeatureModel.h"
#import "[StyleNamesHeader].h"
#import "[Prefix]FeatureTableViewCell.h"

// MARK: - Section Keys -

NSString * const [Prefix]FeatureSectionItemsKey = @"feature_section_items";

// MARK: - Class Extension -

@interface [Prefix]FeatureViewController () <[Prefix]FeatureTableViewCellDelegate>

@property (nonatomic, copy, readwrite) NSArray<[Prefix]FeatureModel *> *items;
@property (nonatomic, copy, readwrite) NSArray *sections;
@property (nonatomic, copy, readwrite) NSDictionary *itemsForSection;

@end

// MARK: - Implementation -

@implementation [Prefix]FeatureViewController

- (void)viewDidLoad {
    // Register table view cells BEFORE calling super
    [self.tableView registerTableViewCells:@[
        [[Prefix]FeatureTableViewCell class]
    ]];

    [super viewDidLoad];

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNavigationBar];
}


// MARK: Configure UI

- (void)configureStyles {
    [super configureStyles];

    self.navigationBarView.dyeStyleName = [style_constant];
    self.confirmButton.dyeStyleName = [style_constant];
}

- (void)configureUI {
    [super configureUI];

    [self.confirmButton setTitleForLocalizationKey:@"feature_btn_confirm" forState:UIControlStateNormal];
}


// MARK: Handle Data

- (void)loadData {
    self.items = [[Prefix]FeatureModel allItems];
    [self reloadSections];
    [self updateUI];
}


// MARK: UITableView Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = self.sections[section];
    NSArray *items = self.itemsForSection[sectionKey];
    return items.count;
}

@end
\`\`\`

---

## 2. Creating Table View Cells

[Similar detailed pattern with header and implementation]

---

## 3. Creating Data Models

[Similar detailed pattern with header and implementation]

---

## 4. Style System

### Adding Style Constants

\`\`\`objc
// In [StyleNamesHeader].h
#define feature_section_title @"feature_section_title"
#define feature_section_text @"feature_section_text"
\`\`\`

### Using Styles in Code

\`\`\`objc
// For dyeStyleName property
self.titleLabel.dyeStyleName = feature_section_title;

// For getting colors from styles
self.toggleSwitch.onTintColor = [DYEStyle styleNamed:feature_switch_tint].backgroundColor;
\`\`\`

---

## 5. Localization

\`\`\`objc
// For labels
self.titleLabel.text = [Dialect stringFor:item.titleLocalizationKey];

// For buttons
[self.confirmButton setTitleForLocalizationKey:@"feature_btn_confirm" forState:UIControlStateNormal];
\`\`\`

---

## Quick Reference Checklist

When creating a new feature module:

- [ ] Create folder structure: `Modules/[FeatureName]/`
- [ ] Create subfolders: `Models/`, `Cells/`
- [ ] Create model classes
- [ ] Add style constants to `[StyleNamesHeader].h`
- [ ] Create cell classes with XIB files
- [ ] Create view controller with storyboard
- [ ] Register cells in `viewDidLoad` BEFORE `[super viewDidLoad]`
- [ ] Implement delegate protocols for cell interactions
- [ ] Add localization keys
- [ ] Configure accessibility for all interactive elements
```

**End of iOS example**

---

**Version:** 1.0
**Last Updated:** 2026-02-24
