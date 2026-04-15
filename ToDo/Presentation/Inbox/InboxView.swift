//
//  InboxView.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// Inbox view displaying open (non-archived) todos grouped by date
struct InboxView: View {
    @StateObject var viewModel: InboxViewModel
    @State private var newTodoText: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Quick-add field - always visible
            HStack(spacing: AppSpacing.small) {
                TextField("New todo...", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppColors.primaryText)
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
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.medium)
            .background(AppColors.elevated)

            Divider()

            // Content area
            Group {
                if viewModel.isLoading && viewModel.groups.isEmpty {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.groups.isEmpty {
                    EmptyStateView(
                        title: "No Todos",
                        message: "Your inbox is empty.\nCreate a new todo to get started.",
                        systemImage: "tray"
                    )
                } else {
                    List {
                        ForEach(viewModel.groups) { group in
                            Section {
                                ForEach(group.items) { item in
                                    TodoRowView(
                                        item: item,
                                        onComplete: {
                                            Task {
                                                await viewModel.complete(item)
                                            }
                                        },
                                        onDelete: {
                                            Task {
                                                await viewModel.delete(item)
                                            }
                                        },
                                        onChangePriority: { priority in
                                            Task {
                                                await viewModel.changePriority(item, to: priority)
                                            }
                                        }
                                    )
                                }
                            } header: {
                                SectionHeaderView(title: group.title)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .background(AppColors.background)
        .navigationTitle("Inbox")
        .task {
            await viewModel.load()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    private func createTodo() async {
        await viewModel.create(text: newTodoText)
        newTodoText = ""
        isInputFocused = true
    }
}

#Preview {
    NavigationStack {
        InboxView(
            viewModel: InboxViewModel(
                fetchUseCase: FetchOpenTodosGroupedUseCase(repository: MockTodoRepository()),
                createUseCase: CreateTodoUseCase(
                    repository: MockTodoRepository(),
                    preferencesService: MockPreferencesService()
                ),
                completeUseCase: CompleteTodoUseCase(repository: MockTodoRepository()),
                deleteUseCase: DeleteTodoUseCase(repository: MockTodoRepository()),
                updatePriorityUseCase: UpdateTodoPriorityUseCase(repository: MockTodoRepository())
            )
        )
    }
}
