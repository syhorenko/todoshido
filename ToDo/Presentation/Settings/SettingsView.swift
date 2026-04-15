//
//  SettingsView.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// Settings view for app configuration
struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            // Hotkey Section
            Section("Global Hotkey") {
                HotkeyPicker(
                    keyCode: $viewModel.preferences.hotkeyKeyCode,
                    modifiers: $viewModel.preferences.hotkeyModifiers
                )
                .onChange(of: viewModel.preferences.hotkeyKeyCode) { _ in
                    viewModel.savePreferences()
                }
                .onChange(of: viewModel.preferences.hotkeyModifiers) { _ in
                    viewModel.savePreferences()
                }
            }

            // Duplicate Detection Section
            Section("Capture Settings") {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Duplicate Detection Window")
                        .font(.headline)

                    Slider(
                        value: $viewModel.preferences.duplicateDetectionWindow,
                        in: 5...60,
                        step: 5,
                        onEditingChanged: { editing in
                            if !editing {
                                viewModel.savePreferences()
                            }
                        }
                    )

                    Text("\(Int(viewModel.preferences.duplicateDetectionWindow)) seconds")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }

            // System Integration Section
            Section("System Integration") {
                Toggle("Launch at Login", isOn: Binding(
                    get: { viewModel.launchAtLoginService.isEnabled },
                    set: { _ in viewModel.toggleLaunchAtLogin() }
                ))
            }

            // iCloud Section
            Section("iCloud Sync") {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack {
                        Text("Status:")
                        Spacer()

                        if viewModel.cloudSyncStatusService.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                                .padding(.trailing, AppSpacing.xSmall)
                        }

                        Text(viewModel.cloudSyncStatusService.statusDescription)
                            .foregroundColor(
                                viewModel.cloudSyncStatusService.isEnabled
                                    ? AppColors.accent
                                    : AppColors.secondaryText
                            )
                    }

                    if !viewModel.cloudSyncStatusService.isEnabled {
                        Text("Sign in to iCloud in System Settings to enable sync")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .onReceive(viewModel.cloudSyncStatusService.statusPublisher) { _ in
                // Trigger UI refresh when status changes
            }

            // Reset Button
            Section {
                Button("Reset to Defaults", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 400)
        .background(AppColors.background)
        .alert("Settings Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}
