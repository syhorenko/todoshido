//
//  InboxView.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import SwiftUI

/// Inbox view displaying open (non-archived) todos grouped by date
struct InboxView: View {
    @StateObject var viewModel: InboxViewModel
    @Binding var selectedTodoId: UUID?
    @State private var newTodoText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: 0) {
            // Quick-add field - always visible
            VStack(spacing: AppSpacing.small) {
                HStack(spacing: AppSpacing.small) {
                    TextField("New todo...", text: $newTodoText)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppColors.primaryText)
                        .focused($isInputFocused)
                        .disabled(viewModel.isRecording)
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

                    // Voice capture button
                    if !viewModel.isRecording {
                        Button(action: {
                            Task {
                                await viewModel.startVoiceCapture()
                            }
                        }) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(AppColors.accent)
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            viewModel.stopVoiceCapture()
                        }) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .overlay(
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                                .opacity(pulseAnimation ? 0 : 1)
                        )
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                                pulseAnimation = true
                            }
                        }
                        .onDisappear {
                            pulseAnimation = false
                        }
                    }
                }

                // Show partial transcription while recording
                if viewModel.isRecording && !viewModel.partialTranscription.isEmpty {
                    Text(viewModel.partialTranscription)
                        .foregroundColor(AppColors.secondaryText)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    ScrollViewReader { scrollProxy in
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
                                            },
                                            onEdit: {
                                                viewModel.editingItem = item
                                            },
                                            isSelected: selectedTodoId == item.id
                                        )
                                        .id(item.id)
                                    }
                                } header: {
                                    SectionHeaderView(title: group.title)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .onChange(of: selectedTodoId) { newId in
                            if let id = newId {
                                viewModel.selectTodo(id)
                                withAnimation {
                                    scrollProxy.scrollTo(id, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(AppColors.background)
        .navigationTitle("Inbox")
        .task {
            await viewModel.load()
        }
        .sheet(item: $viewModel.editingItem) { item in
            EditTodoView(item: item) { newText in
                Task {
                    await viewModel.edit(item, text: newText)
                }
            }
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
                updatePriorityUseCase: UpdateTodoPriorityUseCase(repository: MockTodoRepository()),
                updateTodoUseCase: UpdateTodoUseCase(repository: MockTodoRepository())
            ),
            selectedTodoId: .constant(nil)
        )
    }
}
