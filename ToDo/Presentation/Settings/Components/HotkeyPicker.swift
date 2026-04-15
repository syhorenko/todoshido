//
//  HotkeyPicker.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// SwiftUI wrapper for hotkey recording
struct HotkeyPicker: View {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32
    @State private var isRecording: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Capture Shortcut")
                .font(.headline)

            HotkeyRecorder(
                keyCode: $keyCode,
                modifiers: $modifiers,
                isRecording: $isRecording
            )
            .frame(height: 30)

            Text("Click field and press key combination")
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
        }
    }
}
