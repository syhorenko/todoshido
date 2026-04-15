//
//  HotkeyRecorder.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI
import AppKit
import Carbon

/// NSViewRepresentable for recording hotkey combinations
struct HotkeyRecorder: NSViewRepresentable {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32
    @Binding var isRecording: Bool

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.isEditable = false
        textField.isBordered = true
        textField.backgroundColor = .controlBackgroundColor
        textField.placeholderString = "Click to record..."
        textField.stringValue = HotkeyFormatter.displayString(
            modifiers: modifiers,
            keyCode: keyCode
        )
        textField.alignment = .center

        let clickRecognizer = NSClickGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleClick)
        )
        textField.addGestureRecognizer(clickRecognizer)

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if isRecording {
            nsView.stringValue = "Press keys..."
            nsView.becomeFirstResponder()
            context.coordinator.startRecording(nsView)
        } else {
            nsView.stringValue = HotkeyFormatter.displayString(
                modifiers: modifiers,
                keyCode: keyCode
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(keyCode: $keyCode, modifiers: $modifiers, isRecording: $isRecording)
    }

    class Coordinator: NSObject {
        @Binding var keyCode: UInt32
        @Binding var modifiers: UInt32
        @Binding var isRecording: Bool

        private var monitor: Any?

        init(keyCode: Binding<UInt32>, modifiers: Binding<UInt32>, isRecording: Binding<Bool>) {
            _keyCode = keyCode
            _modifiers = modifiers
            _isRecording = isRecording
        }

        @objc func handleClick() {
            isRecording = true
        }

        func startRecording(_ textField: NSTextField) {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self = self else { return event }

                // Validate at least one modifier
                let eventModifiers = event.modifierFlags
                let hasModifier = eventModifiers.contains(.command) ||
                                  eventModifiers.contains(.shift) ||
                                  eventModifiers.contains(.option) ||
                                  eventModifiers.contains(.control)

                guard hasModifier else {
                    Logger.debug("Hotkey must have at least one modifier", category: "settings")
                    return nil
                }

                // Capture key combination
                let carbonModifiers = self.carbonModifiers(from: eventModifiers)
                self.keyCode = UInt32(event.keyCode)
                self.modifiers = carbonModifiers

                self.stopRecording()
                return nil
            }
        }

        func stopRecording() {
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            isRecording = false
        }

        private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
            var carbonMods: UInt32 = 0
            if flags.contains(.command) { carbonMods |= UInt32(cmdKey) }
            if flags.contains(.shift) { carbonMods |= UInt32(shiftKey) }
            if flags.contains(.option) { carbonMods |= UInt32(optionKey) }
            if flags.contains(.control) { carbonMods |= UInt32(controlKey) }
            return carbonMods
        }

        deinit {
            stopRecording()
        }
    }
}
