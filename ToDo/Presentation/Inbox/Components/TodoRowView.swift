//
//  TodoRowView.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// Individual todo item row view
struct TodoRowView: View {
    let item: TodoItem
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(item.text)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(3)
                    .font(.body)

                HStack(spacing: AppSpacing.small) {
                    if let appName = item.sourceAppName {
                        Label(appName, systemImage: "app.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }

                    Text(item.createdAt, style: .time)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }

            Spacer()

            Button(action: onComplete) {
                Image(systemName: "checkmark.circle")
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
        text: "Review pull request for new feature implementation",
        createdAt: Date(),
        updatedAt: Date(),
        completedAt: nil,
        status: .active,
        sourceAppName: "GitHub",
        sourceBundleID: "com.github.desktop",
        captureMethod: .clipboardShortcut
    )

    return List {
        TodoRowView(
            item: sampleItem,
            onComplete: {},
            onDelete: {}
        )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(AppColors.background)
}
