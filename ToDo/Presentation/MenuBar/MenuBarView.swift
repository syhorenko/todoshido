//
//  MenuBarView.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// Menu bar popover view showing recent todos
struct MenuBarView: View {
    @StateObject var viewModel: MenuBarViewModel
    @State private var newTodoText: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Recent Todos")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            .padding(AppSpacing.medium)
            .background(AppColors.surface)

            Divider()

            // Quick-add field
            HStack(spacing: AppSpacing.small) {
                TextField("New todo...", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppColors.primaryText)
                    .font(.body)
                    .focused($isInputFocused)
                    .onSubmit {
                        Task {
                            await createTodo()
                        }
                    }

                if !newTodoText.isEmpty {
                    Button(action: {
                        Task {
                            await createTodo()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.accent)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.medium)
            .background(AppColors.elevated)

            Divider()

            // Content
            Group {
                if viewModel.isLoading && viewModel.recentTodos.isEmpty {
                    ProgressView()
                        .controlSize(.small)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(height: 100)
                } else if viewModel.recentTodos.isEmpty {
                    VStack(spacing: AppSpacing.small) {
                        Image(systemName: "checkmark.circle")
                            .font(.title)
                            .foregroundColor(AppColors.secondaryText)
                        Text("No open todos")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(AppColors.background)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.recentTodos) { item in
                                TodoRowView(
                                    item: item,
                                    onComplete: {
                                        Task {
                                            await viewModel.complete(item)
                                        }
                                    },
                                    onDelete: {},  // No delete in menu bar
                                    isCompact: true
                                )
                                .padding(.horizontal, AppSpacing.medium)

                                if item.id != viewModel.recentTodos.last?.id {
                                    Divider()
                                        .padding(.leading, AppSpacing.medium)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                    .background(AppColors.background)
                }
            }

            Divider()

            // Footer - Open App button
            Button(action: {
                NSApplication.shared.activate(ignoringOtherApps: true)
            }) {
                HStack {
                    Image(systemName: "arrow.up.forward.app")
                    Text("Open App")
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.small)
            }
            .buttonStyle(.plain)
            .background(AppColors.surface)
        }
        .frame(width: 300)
        .task {
            await viewModel.load()
        }
    }

    private func createTodo() async {
        await viewModel.create(text: newTodoText)
        newTodoText = ""
        isInputFocused = true  // Keep focus for multiple entries
    }
}
