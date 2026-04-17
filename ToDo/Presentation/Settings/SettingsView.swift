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
            // General Section
            Section("General") {
                Picker("Default Priority", selection: $viewModel.preferences.defaultTodoPriority) {
                    ForEach([TodoPriority.low, .normal, .high, .urgent], id: \.self) { priority in
                        HStack(spacing: AppSpacing.small) {
                            Circle()
                                .fill(priority.color)
                                .frame(width: 8, height: 8)
                            Text(priority.displayName)
                        }
                        .tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.preferences.defaultTodoPriority) { _ in
                    viewModel.savePreferences()
                }
            }

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

                    // Show error message if present
                    if let errorMessage = viewModel.syncErrorMessage {
                        HStack(alignment: .top, spacing: AppSpacing.small) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)

                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, AppSpacing.xSmall)
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

            // Data Management Section
            Section("Data Management") {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Backup and restore your todos")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)

                    HStack(spacing: AppSpacing.medium) {
                        Button(action: { viewModel.exportTodos() }) {
                            Label("Export All Todos", systemImage: "arrow.down.doc")
                        }

                        Button(action: { viewModel.importTodos() }) {
                            Label("Import Todos", systemImage: "arrow.up.doc")
                        }
                    }

                    // Show success message if present
                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, AppSpacing.xSmall)
                    }
                }
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
