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
    var isCompact: Bool = false  // Compact mode for menu bar

    var body: some View {
        HStack(alignment: .top, spacing: isCompact ? AppSpacing.small : AppSpacing.medium) {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(item.text)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(isCompact ? 2 : 3)
                    .font(isCompact ? .caption : .body)

                // Hide metadata in compact mode
                if !isCompact {
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
            }

            Spacer()

            Button(action: onComplete) {
                Image(systemName: "checkmark.circle")
                    .font(isCompact ? .body : .title2)
                    .foregroundColor(AppColors.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, isCompact ? AppSpacing.xSmall : AppSpacing.small)
        .listRowBackground(AppColors.surface)
        // Only show swipe actions in non-compact mode
        .if(!isCompact) { view in
            view.swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Conditionally apply a transformation to a view
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
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
