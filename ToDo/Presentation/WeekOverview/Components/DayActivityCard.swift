//
//  DayActivityCard.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import SwiftUI

/// Card showing activity for a single day
struct DayActivityCard: View {
    let dayActivity: DayActivity

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            // Day header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayActivity.shortDayName)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(dayActivity.dayOfMonth)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(dayActivity.isToday ? AppColors.accent : AppColors.primaryText)
                }

                Spacer()

                // Activity count badge
                if dayActivity.totalActivity > 0 {
                    Text("\(dayActivity.totalActivity)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.elevated)
                        .cornerRadius(12)
                }
            }

            Divider()

            // Created todos (green background for completed, red for open)
            if !dayActivity.createdTodos.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("Created")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)

                    ForEach(dayActivity.createdTodos.prefix(5)) { todo in
                        HStack(spacing: AppSpacing.xSmall) {
                            Circle()
                                .fill(todo.status.isArchived ? Color.green : Color.red)
                                .frame(width: 6, height: 6)

                            Text(todo.text)
                                .font(.caption)
                                .foregroundColor(AppColors.primaryText)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, AppSpacing.small)
                        .padding(.vertical, 4)
                        .background(
                            todo.status.isArchived
                                ? Color.green.opacity(0.1)
                                : Color.red.opacity(0.1)
                        )
                        .cornerRadius(4)
                    }

                    if dayActivity.createdTodos.count > 5 {
                        Text("+\(dayActivity.createdTodos.count - 5) more")
                            .font(.caption2)
                            .foregroundColor(AppColors.secondaryText)
                            .padding(.leading, AppSpacing.small)
                    }
                }
            }

            // Completed todos (green background)
            if !dayActivity.completedTodos.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)

                    ForEach(dayActivity.completedTodos.prefix(5)) { todo in
                        HStack(spacing: AppSpacing.xSmall) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)

                            Text(todo.text)
                                .font(.caption)
                                .foregroundColor(AppColors.primaryText)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, AppSpacing.small)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                    }

                    if dayActivity.completedTodos.count > 5 {
                        Text("+\(dayActivity.completedTodos.count - 5) more")
                            .font(.caption2)
                            .foregroundColor(AppColors.secondaryText)
                            .padding(.leading, AppSpacing.small)
                    }
                }
            }

            // Empty state
            if dayActivity.createdTodos.isEmpty && dayActivity.completedTodos.isEmpty {
                Text("No activity")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.medium)
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

#Preview {
    let sampleDay = DayActivity(
        date: Date(),
        createdTodos: [
            TodoItem(
                id: UUID(),
                text: "Review pull request",
                createdAt: Date(),
                updatedAt: Date(),
                completedAt: Date(),
                status: .archived,
                sourceAppName: "GitHub",
                sourceBundleID: "com.github.desktop",
                captureMethod: .clipboardShortcut
            ),
            TodoItem(
                id: UUID(),
                text: "Update documentation",
                createdAt: Date(),
                updatedAt: Date(),
                completedAt: nil,
                status: .active,
                sourceAppName: nil,
                sourceBundleID: nil,
                captureMethod: .manualEntry
            )
        ],
        completedTodos: [
            TodoItem(
                id: UUID(),
                text: "Fix navigation bug",
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date(),
                completedAt: Date(),
                status: .archived,
                sourceAppName: "Linear",
                sourceBundleID: "com.linear.app",
                captureMethod: .clipboardShortcut
            )
        ]
    )

    return DayActivityCard(dayActivity: sampleDay)
        .padding()
        .background(AppColors.background)
}
