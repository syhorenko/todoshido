//
//  CarbonHotkeyService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Carbon

/// Carbon framework implementation of HotkeyService
/// Uses RegisterEventHotKey API to register global keyboard shortcuts
@MainActor
final class CarbonHotkeyService: HotkeyService {
    private var hotkeys: [String: EventHotKeyRef?] = [:]
    private var handlers: [String: () -> Void] = [:]
    private var eventHandlerRef: EventHandlerRef?

    enum HotkeyError: Error {
        case registrationFailed(OSStatus)
        case alreadyRegistered(String)
    }

    init() {
        installEventHandler()
    }

    deinit {
        // Clean up all hotkeys
        for identifier in Array(hotkeys.keys) {
            unregister(identifier: identifier)
        }

        // Remove event handler
        if let handlerRef = eventHandlerRef {
            RemoveEventHandler(handlerRef)
        }
    }

    func register(
        configuration: HotkeyConfiguration,
        handler: @escaping () -> Void
    ) throws {
        // Check if already registered
        guard hotkeys[configuration.identifier] == nil else {
            throw HotkeyError.alreadyRegistered(configuration.identifier)
        }

        // Create EventHotKeyID
        var hotkeyID = EventHotKeyID()
        hotkeyID.signature = UTGetOSTypeFromString("TDCP" as CFString)
        hotkeyID.id = UInt32(bitPattern: Int32(truncatingIfNeeded: configuration.identifier.hashValue))

        // Register the hotkey
        var hotkeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            configuration.keyCode,
            configuration.modifiers,
            hotkeyID,
            GetEventDispatcherTarget(),
            0,
            &hotkeyRef
        )

        guard status == noErr else {
            Logger.error("Failed to register hotkey: \(status)", category: "hotkey")
            throw HotkeyError.registrationFailed(status)
        }

        // Store reference and handler
        hotkeys[configuration.identifier] = hotkeyRef
        handlers[configuration.identifier] = handler

        Logger.info("Registered hotkey: \(configuration.identifier)", category: "hotkey")
    }

    func unregister(identifier: String) {
        guard let hotkeyRef = hotkeys[identifier], let ref = hotkeyRef else {
            return
        }

        UnregisterEventHotKey(ref)
        hotkeys.removeValue(forKey: identifier)
        handlers.removeValue(forKey: identifier)

        Logger.info("Unregistered hotkey: \(identifier)", category: "hotkey")
    }

    // MARK: - Event Handler

    private func installEventHandler() {
        var eventTypes = [EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                        eventKind: UInt32(kEventHotKeyPressed))]

        let callback: EventHandlerUPP = { (nextHandler, event, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }

            let service = Unmanaged<CarbonHotkeyService>.fromOpaque(userData).takeUnretainedValue()

            // Get hotkey ID from event
            var hotkeyID = EventHotKeyID()
            GetEventParameter(
                event,
                UInt32(kEventParamDirectObject),
                UInt32(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotkeyID
            )

            // Find and call handler
            Task { @MainActor in
                service.handleHotkeyPressed(hotkeyID: hotkeyID)
            }

            return noErr
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetEventDispatcherTarget(),
            callback,
            1,
            &eventTypes,
            selfPtr,
            &eventHandlerRef
        )
    }

    private func handleHotkeyPressed(hotkeyID: EventHotKeyID) {
        // Find handler by matching hotkey ID
        for (identifier, handler) in handlers {
            let expectedID = UInt32(bitPattern: Int32(truncatingIfNeeded: identifier.hashValue))
            if hotkeyID.id == expectedID {
                Logger.debug("Hotkey pressed: \(identifier)", category: "hotkey")
                handler()
                return
            }
        }
    }
}
