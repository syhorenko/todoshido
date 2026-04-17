# Session: Add Voice-to-Text Task Creation

**Date:** 2026-04-17  
**Topic:** Voice Capture Feature

---

## Session Summary

Implemented complete voice-to-text capture functionality using Apple's Speech framework. Users can now create todos by speaking into their microphone. The feature includes live transcription preview, auto-stop after silence, duplicate detection, and follows the existing Clean Architecture patterns. This is the third capture method alongside clipboard hotkey and manual entry.

---

## Changes Made

### Files Created

1. **ToDo/Platform/SpeechRecognition/SpeechRecognitionService.swift**
   - Protocol for speech recognition services
   - Defines authorization, recognition, and stop methods
   - Custom `SpeechRecognitionError` enum with localized descriptions
   - Platform-agnostic interface

2. **ToDo/Platform/SpeechRecognition/SFSpeechRecognitionService.swift**
   - Implementation using Apple's `Speech` framework
   - `@MainActor` for thread safety
   - Live transcription with partial results callback
   - Auto-stop after 2 seconds of silence
   - macOS-compatible (no iOS-specific AVAudioSession calls)
   - Audio engine management with proper cleanup

3. **ToDo/Domain/UseCases/CaptureTodoFromVoiceUseCase.swift**
   - Use case for voice capture following existing patterns
   - Mirrors `CaptureTodoFromClipboardUseCase` structure
   - Authorization request handling
   - Duplicate detection with configurable time window
   - Creates todo with `.voiceCapture` method
   - Proper error handling and logging

### Files Modified

4. **ToDo/Domain/Models/CaptureMethod.swift**
   - Added `case voiceCapture` to enum
   - Maintains `Int16` and `Codable` conformance for database persistence

5. **ToDo/Presentation/Inbox/InboxViewModel.swift**
   - Added `@Published var isRecording = false` for UI state
   - Added `@Published var partialTranscription = ""` for live updates
   - Added `voiceCaptureUseCase: CaptureTodoFromVoiceUseCase?` property (optional)
   - Updated `init()` with optional voice capture parameter
   - Added `startVoiceCapture()` async method with partial callback
   - Added `stopVoiceCapture()` method
   - Handles duplicate capture silently (matches clipboard behavior)

6. **ToDo/Presentation/Inbox/InboxView.swift**
   - Added `@State private var pulseAnimation = false` for recording indicator
   - Added microphone button after "+" button in quick-add field
   - Button shows red pulsing animation while recording
   - Displays `partialTranscription` below field during recording
   - TextField disabled while recording to avoid conflicts
   - Wrapped quick-add in VStack to accommodate transcription preview

7. **ToDo/App/AppCoordinator.swift**
   - Created `SFSpeechRecognitionService` instance in `makeInboxView()`
   - Created `CaptureTodoFromVoiceUseCase` with dependencies
   - Injected into `InboxViewModel` initialization

8. **ToDo/Info.plist**
   - Added `NSSpeechRecognitionUsageDescription` permission
   - Added `NSMicrophoneUsageDescription` permission
   - Clear user-facing descriptions explaining why access is needed

---

## Key Decisions

### Speech Framework Choice
- **Decision:** Use Apple's built-in Speech framework (`SFSpeechRecognizer`)
- **Rationale:** Native, free, offline-capable, privacy-friendly, excellent accuracy
- **Alternative Rejected:** Third-party APIs (cost, privacy, network dependency)

### UI Pattern
- **Microphone button**: Placed in quick-add field for discoverability
- **Live transcription**: Shows partial results as user speaks (better UX)
- **Visual feedback**: Red pulsing animation during recording
- **Auto-stop**: 2 seconds of silence finalizes recording
- **Manual stop**: Tap mic button again to cancel

### Platform Compatibility
- **macOS-specific**: Removed iOS-only `AVAudioSession` configuration
- **Audio Engine**: Direct use of `AVAudioEngine` works on macOS without session management
- **Permissions**: Uses macOS permission system via Info.plist

### Architecture
- **Clean Architecture**: Follows existing Use Case → Repository pattern
- **Platform Services**: New `Platform/SpeechRecognition/` directory following established pattern
- **Optional Dependency**: Voice capture is optional in InboxViewModel for backwards compatibility
- **Duplicate Detection**: Reuses existing duplicate detection window from preferences

---

## Next Steps

### Testing Checklist
1. **Build**: ✅ Succeeded
2. **Run app**: Test in macOS environment
3. **Permission flow**:
   - First tap mic → system permission dialog appears
   - Grant permission → recording starts
   - Deny permission → error alert shown
4. **Recording**:
   - Speak "Buy milk and bread"
   - Verify partial transcription appears live
   - Wait 2s after speaking → todo auto-created
   - Check `captureMethod` is `.voiceCapture`
5. **UI feedback**:
   - Red pulsing animation while recording
   - Partial transcription display
   - TextField disabled during recording
6. **Duplicate detection**:
   - Say same text twice within 10s → second silently ignored
7. **Error handling**:
   - Test background noise handling
   - Test silence (no speech) → error shown
8. **Cross-view sync**:
   - Voice capture in Inbox → MenuBar updates

### Future Enhancements
- **Hotkey trigger**: Add global hotkey for voice capture (like clipboard hotkey)
- **Multi-language**: Support language selection in settings
- **Voice commands**: "High priority buy milk" → auto-set priority
- **Continuous mode**: Keep mic open for multiple todos
- **Noise cancellation**: Improve accuracy in noisy environments

---

## Commands Reference

```bash
# Build
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido build

# Check mic permissions (Terminal)
# System Preferences → Security & Privacy → Microphone

# Test Speech Recognition API
# Speak clearly, pause 2 seconds after finishing

# Commit (when tested)
git add ToDo/Platform/SpeechRecognition/
git add ToDo/Domain/UseCases/CaptureTodoFromVoiceUseCase.swift
git add ToDo/Domain/Models/CaptureMethod.swift
git add ToDo/Presentation/Inbox/InboxViewModel.swift
git add ToDo/Presentation/Inbox/InboxView.swift
git add ToDo/App/AppCoordinator.swift
git add ToDo/Info.plist
git commit -m "Add voice-to-text todo capture feature

Users can now create todos by speaking into the microphone.

Features:
- Microphone button in quick-add field
- Live transcription preview while speaking
- Auto-stop after 2 seconds of silence
- Red pulsing animation during recording
- Duplicate detection (same as clipboard)
- Uses Apple Speech framework (offline-capable)
- macOS compatible audio handling

Technical:
- New SpeechRecognitionService platform service
- CaptureTodoFromVoiceUseCase following existing patterns
- Added .voiceCapture to CaptureMethod enum
- Microphone and speech recognition permissions

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Technical Notes

### Speech Framework Features Used
- **SFSpeechRecognizer**: On-device speech recognition
- **Live results**: `shouldReportPartialResults = true`
- **Automatic punctuation**: Adds periods, commas, etc.
- **Locale support**: Uses `Locale.current` for user's language

### Audio Engine Configuration
- **Input node**: Captures microphone audio
- **Buffer size**: 1024 samples for real-time processing
- **Format**: Uses `inputNode.outputFormat(forBus: 0)`
- **Tap installation**: `installTap(onBus:bufferSize:format:)`

### Auto-Stop Logic
- Tracks last speech timestamp
- Checks every 0.5 seconds for silence duration
- 2-second silence threshold triggers finalization
- Prevents "no speech detected" error if speech was recognized

### Duplicate Detection
- Uses same mechanism as clipboard capture
- Configurable window via `AppPreferences.duplicateDetectionWindow`
- Default: 10 seconds
- Cache cleanup after window expires

### Privacy & Permissions
- **First request**: System modal dialog with Info.plist message
- **Authorization check**: Before every recognition session
- **Graceful failure**: Clear error messages if denied
- **No data sent**: On-device processing preserves privacy

### macOS vs iOS Differences
- **macOS**: No `AVAudioSession` required
- **iOS**: Would need `AVAudioSession` configuration
- **Current impl**: macOS-only, iOS support would require platform checks

---

## Architecture Adherence

✅ **Clean Architecture**: Use Case layer separated from platform details  
✅ **Platform Services Pattern**: `SpeechRecognitionService` protocol + implementation  
✅ **MVVM**: ViewModel handles business logic, View is declarative  
✅ **Dependency Injection**: All services injected via AppCoordinator  
✅ **Reactive Updates**: Uses `@Published` for UI state  
✅ **Error Handling**: Localized errors with user-friendly messages  
✅ **Logging**: Uses `Logger` for debugging and analytics  
✅ **Duplicate Detection**: Consistent with existing capture methods  

---

## Lessons Learned

### macOS Audio Configuration
- **Lesson**: `AVAudioSession` is iOS/tvOS-only, not available on macOS
- **Solution**: Use `AVAudioEngine` directly without session configuration
- **Applies to**: Any cross-platform audio work

### Speech Recognition Best Practices
- **Partial results**: Greatly improves UX (shows progress)
- **Auto-stop**: Users don't want to manually stop recording
- **Silence detection**: 2 seconds is a good balance (not too fast, not too slow)

### Optional Dependencies
- **Pattern**: Make new features optional in ViewModels for backwards compatibility
- **Benefit**: Previews and tests don't require full dependency setup
- **Example**: `voiceCaptureUseCase: CaptureTodoFromVoiceUseCase? = nil`

---

**Implementation Time:** ~2 hours  
**Files Changed:** 8 (3 new, 5 modified)  
**Lines Added:** ~350  
**Build Status:** ✅ Success  
**Platform:** macOS (iOS-compatible with minor changes)
