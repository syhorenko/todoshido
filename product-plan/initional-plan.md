{\rtf1\ansi\ansicpg1252\cocoartf2869
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 .SFNS-Regular;\f1\fnil\fcharset0 HelveticaNeue-Bold;\f2\fnil\fcharset0 .AppleSystemUIFontMonospaced-Regular;
\f3\fnil\fcharset0 .SFNS-Semibold;\f4\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;\red14\green14\blue14;}
{\*\expandedcolortbl;;\cssrgb\c6700\c6700\c6700;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 What you want is basically a 
\f1\b personal capture inbox
\f0\b0  for text snippets that turn into todos, with context and automatic history. The strongest version of it is:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	capture text quickly from anywhere\
	\'95	keep the source context\
	\'95	show everything in one persistent list\
	\'95	mark done \uc0\u8594  move to archive\
	\'95	group unfinished items by day\
	\'95	sync through iCloud\
	\'95	later reuse the same data layer for iPhone and iPad\
\
The key technical detail is this: on macOS, the most practical MVP is 
\f1\b capture-from-clipboard plus global shortcut
\f0\b0 , not \'93read selected text directly from any app\'94 on day one. 
\f2 NSPasteboard
\f0  is the standard interface for pasteboard data, and 
\f2 changeCount
\f0  lets you detect when the clipboard changes. You can also identify the frontmost app with 
\f2 NSWorkspace.shared.frontmostApplication
\f0 . For sync, Apple\'92s Core Data + CloudKit path is the most proven route for this kind of app. App Intents / App Shortcuts are also a good fit for later automation and shortcut-based capture flows.  \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Product direction
\f0\b0\fs26 \
\
I would frame the app around three concepts:\
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	1.	
\f1\b Inbox
\f0\b0 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\li400\sl324\slmult1\pardirnatural\partightenfactor0
\cf2 Every captured text snippet lands here immediately.\
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	2.	
\f1\b Today / Previous Days
\f0\b0 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\li400\sl324\slmult1\pardirnatural\partightenfactor0
\cf2 Open items stay visible until done, grouped by capture date.\
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	3.	
\f1\b Archive
\f0\b0 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\li400\sl324\slmult1\pardirnatural\partightenfactor0
\cf2 Completed items move here automatically with completion timestamp.\
\
That gives you a simple mental model:\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 capture fast now, organize lightly later, finish and archive
\f0\b0 .\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Best MVP behavior
\f0\b0\fs26 \
\
For version 1 on macOS:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	User selects text in any app\
	\'95	User presses 
\f1\b Cmd+C
\f0\b0 \
	\'95	User presses your app shortcut, for example 
\f1\b Cmd+Shift+T
\f0\b0 \
	\'95	Your app creates a todo from current clipboard text\
	\'95	Metadata saved:\
\pard\tqr\tx500\tx660\li660\fi-660\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	captured text\
	\'95	created date/time\
	\'95	source app name\
	\'95	maybe bundle identifier\
	\'95	optional note/status\
\
This is much more realistic than trying to read arbitrary selected text from every app immediately. Direct access to selected text across other apps usually pushes you toward Accessibility-based integration, which is better treated as a phase-2 feature, not the foundation of v1. Apple exposes selected-text accessibility APIs, but building a robust cross-app capture flow around that is a separate level of complexity and permissions work.  \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Recommended architecture
\f0\b0\fs26 \
\
You said 
\f1\b Swift + SwiftUI + MVVM-C
\f0\b0 , and that fits well.\
\
I would structure it like this:\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 1. App layers
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Presentation
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	SwiftUI views\
	\'95	ViewModels\
	\'95	design system / theme\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Coordination
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	AppCoordinator\
	\'95	InboxCoordinator\
	\'95	ArchiveCoordinator\
	\'95	SettingsCoordinator\
	\'95	CaptureCoordinator\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Domain
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	TodoItem\
	\'95	CaptureRecord\
	\'95	TodoGroupingService\
	\'95	CaptureUseCase\
	\'95	CompleteTodoUseCase\
	\'95	RestoreTodoUseCase\
	\'95	SearchTodosUseCase\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Data
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	Repository protocols\
	\'95	Core Data implementation\
	\'95	Cloud sync integration\
	\'95	local settings storage\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Platform services
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	ClipboardMonitor\
	\'95	GlobalHotkeyService\
	\'95	FrontmostAppService\
	\'95	AccessibilityCaptureService later\
	\'95	NotificationService optional later\
\
This keeps SwiftUI clean and prevents the ViewModel from becoming a giant service hub.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Suggested data model
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Entity: TodoItem
\f0\b0\fs26 \
\
Fields:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 id: UUID
\f0 \
	\'95	
\f2 text: String
\f0 \
	\'95	
\f2 createdAt: Date
\f0 \
	\'95	
\f2 updatedAt: Date
\f0 \
	\'95	
\f2 completedAt: Date?
\f0 \
	\'95	
\f2 status: TodoStatus
\f0 \
	\'95	
\f2 sourceAppName: String?
\f0 \
	\'95	
\f2 sourceBundleID: String?
\f0 \
	\'95	
\f2 sourceWindowTitle: String?
\f0  later if possible\
	\'95	
\f2 captureMethod: CaptureMethod
\f0 \
	\'95	
\f2 capturedPlainText: String
\f0 \
	\'95	
\f2 capturedOriginalContentType: String?
\f0 \
	\'95	
\f2 groupDay: Date
\f0 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\li260\sl324\slmult1\pardirnatural\partightenfactor0
\cf2 normalized to start-of-day for grouping\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 isArchived: Bool
\f0 \
	\'95	
\f2 sortOrder: Double
\f0  if manual ordering is needed later\
	\'95	
\f2 note: String?
\f0 \
	\'95	
\f2 tags: [String]
\f0  later, or separate entity\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Enum: TodoStatus
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	active\
	\'95	done\
	\'95	archived\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Enum: CaptureMethod
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	clipboardShortcut\
	\'95	manualEntry\
	\'95	shareExtension later\
	\'95	accessibilitySelection later\
	\'95	shortcutIntent later\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Optional entity later: CaptureSource
\f0\b0\fs26 \
\
If you want more detailed provenance in the future.\
\
For v1, keeping source fields directly on 
\f2 TodoItem
\f0  is simpler.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Core user flows
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Flow 1: Quick capture
\f0\b0\fs26 \
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	1.	User copies text\
	2.	Presses global shortcut\
	3.	App reads clipboard\
	4.	App asks 
\f2 NSWorkspace.shared.frontmostApplication
\f0 \
	5.	App stores todo\
	6.	Small confirmation appears:\
\pard\tqr\tx500\tx660\li660\fi-660\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	menu bar popover\
	\'95	HUD/toast\
	\'95	or subtle notification\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Flow 2: Review list
\f0\b0\fs26 \
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	1.	Open main app window\
	2.	Default screen = open items grouped by date\
	3.	Each cell shows:\
\pard\tqr\tx500\tx660\li660\fi-660\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	text preview\
	\'95	source app\
	\'95	time captured\
	\'95	done button\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Flow 3: Complete item
\f0\b0\fs26 \
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	1.	User marks item done\
	2.	Status changes to done\
	3.	Item disappears from open list\
	4.	Moves to archive section\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Flow 4: Archive review
\f0\b0\fs26 \
\pard\tqr\tx240\tx400\li400\fi-400\sl324\slmult1\sb240\partightenfactor0
\cf2 	1.	User opens archive\
	2.	Sees completed items grouped by completion date or creation date\
	3.	Can restore or delete permanently\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 macOS app shape
\f0\b0\fs26 \
\
For your use case, I would make this a 
\f1\b hybrid app
\f0\b0 :\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	regular SwiftUI app window\
	\'95	
\f1\b menu bar extra
\f0\b0  for quick access\
	\'95	background-friendly behavior\
	\'95	optional launch at login\
\
That is better than only a normal window app because capture utilities feel much nicer when always available from the menu bar.\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Recommended macOS structure
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 WindowGroup
\f0  for full app\
	\'95	
\f2 MenuBarExtra
\f0  for quick view / recent captures\
	\'95	app runs quietly after login\
	\'95	settings window for shortcut and capture preferences\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Capture strategy: what to build first
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Phase 1 \'97 Clipboard-based capture
\f0\b0\fs26 \
\
This should be your first shippable path.\
\
Components:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 ClipboardReader
\f0 \
	\'95	
\f2 ClipboardChangeTracker
\f0 \
	\'95	
\f2 CaptureShortcutHandler
\f0 \
	\'95	
\f2 FrontmostAppResolver
\f0 \
\
Behavior:\
	\'95	read string from general pasteboard\
	\'95	reject empty values\
	\'95	optionally reject duplicates captured within last X seconds\
	\'95	save record\
	\'95	show success UI\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Phase 2 \'97 Better source context
\f0\b0\fs26 \
\
Enhance metadata:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	app name\
	\'95	bundle ID\
	\'95	maybe browser URL later with browser-specific integration\
	\'95	maybe active window title if feasible\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Phase 3 \'97 Direct selected text capture
\f0\b0\fs26 \
\
Possible future path:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	Accessibility permission\
	\'95	try to read selected text from focused UI element\
	\'95	fallback to clipboard if unavailable\
\
I would treat this as an advanced feature because app-to-app behavior can vary a lot.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Storage and sync
\f0\b0\fs26 \
\
For this app, I recommend:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f1\b Core Data
\f0\b0 \
	\'95	
\f2 NSPersistentCloudKitContainer
\f0 \
	\'95	SwiftUI bindings through ViewModels, not raw view-driven persistence\
\
Apple\'92s Core Data + CloudKit integration is specifically designed to sync model objects across a user\'92s devices through iCloud.  \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Why Core Data instead of SwiftData for this app
\f0\b0\fs26 \
\
You absolutely can use SwiftData, but for 
\f1\b MVVM-C + sync + long-term control
\f0\b0 , I would still lean Core Data here because:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	better maturity for complex sync debugging\
	\'95	clearer repository boundaries\
	\'95	easier to keep architecture explicit\
	\'95	more predictable for macOS+iOS shared business logic\
\
If your goal is \'93stable productivity utility first,\'94 Core Data is the safer foundation.\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Persistence setup
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	one persistent container\
	\'95	CloudKit private database\
	\'95	background contexts for capture writes\
	\'95	fetched/grouped queries via repository layer\
	\'95	merge changes into UI context\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Recommended modules / folders
\f0\b0\fs26 \
\
Something like this:\
ToDoApp/\
\uc0\u9500 \u9472 \u9472  App\
\uc0\u9474    \u9500 \u9472 \u9472  ToDoApp.swift\
\uc0\u9474    \u9500 \u9472 \u9472  AppCoordinator.swift\
\uc0\u9474    \u9492 \u9472 \u9472  AppEnvironment.swift\
\uc0\u9500 \u9472 \u9472  Presentation\
\uc0\u9474    \u9500 \u9472 \u9472  Inbox\
\uc0\u9474    \u9500 \u9472 \u9472  Archive\
\uc0\u9474    \u9500 \u9472 \u9472  Settings\
\uc0\u9474    \u9500 \u9472 \u9472  Components\
\uc0\u9474    \u9492 \u9472 \u9472  Theme\
\uc0\u9500 \u9472 \u9472  Coordinators\
\uc0\u9474    \u9500 \u9472 \u9472  InboxCoordinator.swift\
\uc0\u9474    \u9500 \u9472 \u9472  ArchiveCoordinator.swift\
\uc0\u9474    \u9500 \u9472 \u9472  SettingsCoordinator.swift\
\uc0\u9474    \u9492 \u9472 \u9472  CaptureCoordinator.swift\
\uc0\u9500 \u9472 \u9472  Domain\
\uc0\u9474    \u9500 \u9472 \u9472  Models\
\uc0\u9474    \u9500 \u9472 \u9472  UseCases\
\uc0\u9474    \u9500 \u9472 \u9472  Repositories\
\uc0\u9474    \u9492 \u9472 \u9472  Services\
\uc0\u9500 \u9472 \u9472  Data\
\uc0\u9474    \u9500 \u9472 \u9472  CoreData\
\uc0\u9474    \u9500 \u9472 \u9472  Repositories\
\uc0\u9474    \u9492 \u9472 \u9472  Mappers\
\uc0\u9500 \u9472 \u9472  Platform\
\uc0\u9474    \u9500 \u9472 \u9472  Clipboard\
\uc0\u9474    \u9500 \u9472 \u9472  Hotkeys\
\uc0\u9474    \u9500 \u9472 \u9472  Workspace\
\uc0\u9474    \u9500 \u9472 \u9472  Accessibility\
\uc0\u9474    \u9492 \u9472 \u9472  Notifications\
\uc0\u9500 \u9472 \u9472  Shared\
\uc0\u9474    \u9500 \u9472 \u9472  Extensions\
\uc0\u9474    \u9500 \u9472 \u9472  Utilities\
\uc0\u9474    \u9492 \u9472 \u9472  Constants\
\uc0\u9492 \u9472 \u9472  Resources\
\

\f3\b\fs32 MVVM-C mapping
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Coordinators
\f0\b0\fs26 \
\
Handle:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	navigation\
	\'95	window/panel presentation\
	\'95	menu bar flows\
	\'95	settings routing\
	\'95	deep links / shortcuts later\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 ViewModels
\f0\b0\fs26 \
\
Handle:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	screen state\
	\'95	filtering\
	\'95	grouping\
	\'95	user actions\
	\'95	calling use cases\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Use Cases
\f0\b0\fs26 \
\
Examples:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 CaptureTodoFromClipboardUseCase
\f0 \
	\'95	
\f2 CreateTodoUseCase
\f0 \
	\'95	
\f2 FetchOpenTodosGroupedUseCase
\f0 \
	\'95	
\f2 CompleteTodoUseCase
\f0 \
	\'95	
\f2 RestoreArchivedTodoUseCase
\f0 \
	\'95	
\f2 DeleteArchivedTodoUseCase
\f0 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Repositories
\f0\b0\fs26 \
\
Examples:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 TodoRepository
\f0 \
	\'95	
\f2 SettingsRepository
\f0 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Platform Services
\f0\b0\fs26 \
\
Examples:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f2 PasteboardService
\f0 \
	\'95	
\f2 HotkeyService
\f0 \
	\'95	
\f2 WorkspaceService
\f0 \
\
This makes it much easier to add iOS later without rewriting business logic.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 UI direction
\f0\b0\fs26 \
\
You want a dark palette, which matches this app perfectly.\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Visual style
\f0\b0\fs26 \
\
I would go with:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	charcoal / near-black background\
	\'95	slightly lighter cards\
	\'95	one strong accent color\
	\'95	high contrast text\
	\'95	soft separators, not heavy borders\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Palette suggestion
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	Background: 
\f2 #0B0D10
\f0 \
	\'95	Surface: 
\f2 #12161B
\f0 \
	\'95	Elevated Surface: 
\f2 #181D23
\f0 \
	\'95	Primary Text: 
\f2 #F3F5F7
\f0 \
	\'95	Secondary Text: 
\f2 #98A2B3
\f0 \
	\'95	Accent: 
\f2 #7C5CFF
\f0  or 
\f2 #5EA1FF
\f0 \
	\'95	Success: muted green\
	\'95	Warning: amber\
	\'95	Danger: soft red\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 UI mood
\f0\b0\fs26 \
\
Not colorful, more like:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	clean\
	\'95	focused\
	\'95	low-noise\
	\'95	utility-first\
	\'95	slightly premium\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Main window layout
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Sidebar
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	Inbox\
	\'95	Today\
	\'95	Previous\
	\'95	Archive\
	\'95	Settings\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Content area
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	grouped sections by date\
	\'95	each todo as a card row\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Top bar
\f0\b0 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	search\
	\'95	quick add\
	\'95	capture status\
	\'95	sync indicator optional\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 List row design
\f0\b0\fs26 \
\
Each row can show:\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Main text
\f0\b0 \
captured snippet, 1\'963 lines\
\
Below:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	source app icon + app name\
	\'95	captured time\
	\'95	optional copied badge\
\
Right side:\
	\'95	complete button\
	\'95	more menu\
\
When completed:\
	\'95	animate out from inbox\
	\'95	move to archive\
\
That will feel satisfying and reduce clutter.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Grouping behavior
\f0\b0\fs26 \
\
Your grouping rule should be explicit and simple:\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Open items
\f0\b0\fs26 \
\
Group by 
\f2 createdAt
\f0  day:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	Today\
	\'95	Yesterday\
	\'95	Monday, April 13\
	\'95	Sunday, April 12\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Archive
\f0\b0\fs26 \
\
Either:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	group by 
\f2 completedAt
\f0  day\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\li260\sl324\slmult1\pardirnatural\partightenfactor0
\cf2 or\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	keep a toggle: group by created/completed\
\
For MVP, I\'92d use:\
	\'95	open = grouped by creation day\
	\'95	archive = grouped by completion day\
\
That matches what users usually expect.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Important product decisions
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 1. What counts as duplicate?
\f0\b0\fs26 \
\
You probably need duplicate protection.\
\
Good first rule:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	if same text is captured from same app within 10 seconds, ignore it\
\
Later:\
	\'95	make this configurable\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 2. Should capture auto-trim text?
\f0\b0\fs26 \
\
Yes:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	trim whitespace/newlines at edges\
	\'95	collapse extreme spacing only if safe\
	\'95	preserve internal line breaks when reasonable\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 3. Maximum capture size?
\f0\b0\fs26 \
\
Yes, cap it.\
Example:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	preview text: 300\'96500 chars\
	\'95	full raw text stored separately if needed\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 4. Can user edit captured text?
\f0\b0\fs26 \
\
Yes, definitely.\
Captured text should be editable after creation.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Recommended feature roadmap
\f0\b0\fs26 \
\

\f3\b\fs32 Phase 0 \'97 Product definition
\f0\b0\fs26 \
\
Write down:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	core problem\
	\'95	MVP scope\
	\'95	non-goals\
	\'95	capture flow\
	\'95	sync expectations\
\
Non-goals for v1:\
	\'95	natural language parsing\
	\'95	reminders\
	\'95	tags\
	\'95	collaboration\
	\'95	browser extensions\
	\'95	iOS share extension\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Phase 1 \'97 macOS MVP foundation
\f0\b0\fs26 \
\
Build:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	SwiftUI macOS app\
	\'95	MVVM-C skeleton\
	\'95	Core Data stack\
	\'95	dark theme system\
	\'95	open/archive screens\
	\'95	create/edit/complete/delete todo\
	\'95	grouping by date\
\
Deliverable:\
A local-only todo app with your final data model.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Phase 2 \'97 Background capture
\f0\b0\fs26 \
\
Add:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	menu bar extra\
	\'95	global shortcut\
	\'95	clipboard read\
	\'95	frontmost app metadata\
	\'95	capture toast/HUD\
	\'95	duplicate filtering\
\
Deliverable:\
You can capture copied text from anywhere into the app.\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f2 \cf2 frontmostApplication
\f0  on 
\f2 NSWorkspace
\f0  is the right system hook for identifying the app currently receiving key events.  \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Phase 3 \'97 iCloud sync
\f0\b0\fs26 \
\
Add:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	CloudKit capability\
	\'95	
\f2 NSPersistentCloudKitContainer
\f0 \
	\'95	conflict testing across 2 Macs\
	\'95	offline/online sync checks\
	\'95	migration plan\
\
Deliverable:\
Reliable personal sync across user devices.\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Phase 4 \'97 polish
\f0\b0\fs26 \
\
Add:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	launch at login\
	\'95	settings screen\
	\'95	custom shortcut recorder\
	\'95	search\
	\'95	filters\
	\'95	app icon + branding\
	\'95	accessibility improvements\
	\'95	animations\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Phase 5 \'97 iOS version
\f0\b0\fs26 \
\
Reuse:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	domain\
	\'95	repository interfaces\
	\'95	use cases\
	\'95	theme tokens\
	\'95	most ViewModel logic\
\
New on iOS:\
	\'95	iPhone navigation\
	\'95	share extension later\
	\'95	widget later\
	\'95	App Intents later\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 macOS-specific technical notes
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Global shortcut
\f0\b0\fs26 \
\
You need a robust hotkey layer.\
Create a service like:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	register global shortcut\
	\'95	listen for trigger\
	\'95	call capture use case\
\
Keep this isolated because hotkey code often ends up platform-specific.\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Clipboard monitoring
\f0\b0\fs26 \
\
You do not need constant aggressive polling for v1.\
Better approach:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	read clipboard when shortcut fires\
	\'95	optionally also keep a lightweight change tracker\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Source app
\f0\b0\fs26 \
\
Use:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	localized app name\
	\'95	bundle identifier\
	\'95	optionally app icon for UI\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Background behavior
\f0\b0\fs26 \
\
Make the app feel like a utility:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	continue running after main window closes\
	\'95	menu bar icon remains active\
	\'95	user can reopen main window anytime\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Risks and how to reduce them
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Risk 1: direct text selection capture is unreliable
\f0\b0\fs26 \
\
Mitigation:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	ship clipboard capture first\
	\'95	make direct selection a later experimental feature\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Risk 2: sync conflicts
\f0\b0\fs26 \
\
Mitigation:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	keep model simple\
	\'95	one main entity\
	\'95	avoid complicated relationships in MVP\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Risk 3: too much scope
\f0\b0\fs26 \
\
Mitigation:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	no reminders\
	\'95	no collaboration\
	\'95	no NLP categorization\
	\'95	no tags in first build\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Risk 4: architecture overengineering
\f0\b0\fs26 \
\
Mitigation:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	MVVM-C, but keep coordinators lightweight\
	\'95	one repository\
	\'95	few use cases at the start\
	\'95	only abstract where reuse is obvious\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 My recommended MVP spec
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Must have
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	create todo from clipboard with shortcut\
	\'95	save source app + time\
	\'95	list open todos\
	\'95	group by date\
	\'95	mark done\
	\'95	archive completed items\
	\'95	dark UI\
	\'95	iCloud sync\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Nice to have
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	menu bar quick panel\
	\'95	quick edit\
	\'95	duplicate prevention\
	\'95	launch at login\
	\'95	search\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Later
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	direct selected text capture\
	\'95	iOS app\
	\'95	share extension\
	\'95	App Shortcut integration\
	\'95	widgets\
\
App Intents / App Shortcuts are a strong later addition for automation and shortcut-based creation flows.  \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Suggested first milestone, week by week
\f0\b0\fs26 \
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Milestone 1
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	project setup\
	\'95	folder structure\
	\'95	theme tokens\
	\'95	Core Data entity\
	\'95	inbox + archive screens\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Milestone 2
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	create/edit/complete flows\
	\'95	date grouping\
	\'95	search basics\
	\'95	menu bar shell\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Milestone 3
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	global shortcut\
	\'95	clipboard capture\
	\'95	source app detection\
	\'95	duplicate prevention\
	\'95	capture feedback UI\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs28 \cf2 Milestone 4
\f0\b0\fs26 \
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	CloudKit sync\
	\'95	testing on multiple Macs\
	\'95	conflict/debug fixes\
	\'95	settings and polish\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f4\fs24 \cf0 \
\uc0\u11835 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f0\fs26 \cf2 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f3\b\fs32 \cf2 Final recommendation
\f0\b0\fs26 \
\
If I were building this with your goals, I would choose this stack:\
\pard\tqr\tx100\tx260\li260\fi-260\sl324\slmult1\sb240\partightenfactor0
\cf2 	\'95	
\f1\b Swift
\f0\b0 \
	\'95	
\f1\b SwiftUI
\f0\b0 \
	\'95	
\f1\b MVVM-C
\f0\b0 \
	\'95	
\f1\b Core Data
\f0\b0 \
	\'95	
\f1\b NSPersistentCloudKitContainer
\f0\b0 \
	\'95	
\f1\b menu bar extra
\f0\b0 \
	\'95	
\f1\b global shortcut + clipboard capture for MVP
\f0\b0 \
	\'95	
\f1\b Accessibility-based selected-text capture only later
\f0\b0 \
\
That gives you the highest chance of shipping a useful macOS app quickly, while keeping the path open for iOS.\
\
The most important product choice is this:\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\sl324\slmult1\pardirnatural\partightenfactor0

\f1\b \cf2 Build the app first as a reliable capture inbox, not as a complex cross-app text-extraction engine.}