//
//  EditTodoView.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import SwiftUI

/// Edit sheet for modifying todo item text
struct EditTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editedText: String
    let item: TodoItem
    let onSave: (String) -> Void

    init(item: TodoItem, onSave: @escaping (String) -> Void) {
        self.item = item
        self.onSave = onSave
        _editedText = State(initialValue: item.text)
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $editedText)
                    .font(.body)
                    .foregroundColor(AppColors.primaryText)
                    .scrollContentBackground(.hidden)
                    .background(AppColors.background)
                    .padding()
            }
            .navigationTitle("Edit Todo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(editedText)
                        dismiss()
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    let sampleItem = TodoItem(
        id: UUID(),
        text: "Sample todo text\nWith multiple lines",
        createdAt: Date(),
        updatedAt: Date(),
        completedAt: nil,
        status: .active,
        sourceAppName: nil,
        sourceBundleID: nil,
        captureMethod: .manualEntry
    )

    return EditTodoView(item: sampleItem) { newText in
        print("Saved: \(newText)")
    }
}
