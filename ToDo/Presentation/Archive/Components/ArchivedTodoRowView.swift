//
//  ArchivedTodoRowView.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import SwiftUI

/// Individual archived todo item row view
struct ArchivedTodoRowView: View {
    let item: TodoItem
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            // Priority badge (grayed out for archived items)
            Circle()
                .fill(item.priority.color.opacity(0.5))
                .frame(width: 8, height: 8)
                .padding(.top, 6)  // Align with first line of text
                .accessibilityLabel(item.priority.displayName + " priority")

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(item.text)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(3)
                    .font(.body)
                    .strikethrough()

                HStack(spacing: AppSpacing.small) {
                    if let appName = item.sourceAppName {
                        Label(appName, systemImage: "app.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }

                    if let completedAt = item.completedAt {
                        Text(completedAt, style: .time)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }

            Spacer()

            Button(action: onRestore) {
                Image(systemName: "arrow.uturn.backward.circle")
                    .font(.title2)
                    .foregroundColor(AppColors.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AppSpacing.small)
        .listRowBackground(AppColors.surface)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    let sampleItem = TodoItem(
        id: UUID(),
        text: "Completed task from yesterday",
        createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        updatedAt: Date(),
        completedAt: Date(),
        status: .archived,
        sourceAppName: "Slack",
        sourceBundleID: "com.tinyspeck.slackmacgap",
        captureMethod: .clipboardShortcut
    )

    return List {
        ArchivedTodoRowView(
            item: sampleItem,
            onRestore: {},
            onDelete: {}
        )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(AppColors.background)
}
