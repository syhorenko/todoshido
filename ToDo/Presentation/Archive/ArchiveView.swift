//
//  ArchiveView.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import SwiftUI

/// Archive view displaying completed todos grouped by completion date
struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.groups.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.groups.isEmpty {
                EmptyStateView(
                    title: "No Archived Items",
                    message: "Completed todos will appear here.",
                    systemImage: "archivebox"
                )
            } else {
                List {
                    ForEach(viewModel.groups) { group in
                        Section {
                            ForEach(group.items) { item in
                                ArchivedTodoRowView(
                                    item: item,
                                    onRestore: {
                                        Task {
                                            await viewModel.restore(item)
                                        }
                                    },
                                    onDelete: {
                                        Task {
                                            await viewModel.delete(item)
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
        .background(AppColors.background)
        .navigationTitle("Archive")
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
}

#Preview {
    NavigationStack {
        ArchiveView(
            viewModel: ArchiveViewModel(
                fetchUseCase: FetchArchivedTodosGroupedUseCase(repository: MockTodoRepository()),
                restoreUseCase: RestoreTodoUseCase(repository: MockTodoRepository()),
                deleteUseCase: DeleteTodoUseCase(repository: MockTodoRepository())
            )
        )
    }
}
