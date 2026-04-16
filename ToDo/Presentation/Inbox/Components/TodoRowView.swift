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
    var onChangePriority: ((TodoPriority) -> Void)?
    var isCompact: Bool = false  // Compact mode for menu bar

    @State private var isExpanded = false
    @State private var showPriorityPicker = false

    /// Computed text that removes newlines when collapsed
    private var displayText: String {
        if isExpanded {
            return item.text
        } else {
            // Replace newlines with spaces for compact display
            return item.text.replacingOccurrences(of: "\n", with: " ")
        }
    }

    /// Attributed string with clickable links
    private var attributedText: AttributedString {
        var attributedString = AttributedString(displayText)

        // Detect URLs in the text
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let nsString = displayText as NSString
            let matches = detector.matches(in: displayText, range: NSRange(location: 0, length: nsString.length))

            for match in matches.reversed() {
                if let range = Range(match.range, in: displayText),
                   let url = match.url {
                    let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: match.range.location)
                    let endIndex = attributedString.index(startIndex, offsetByCharacters: match.range.length)
                    attributedString[startIndex..<endIndex].link = url
                }
            }
        }

        return attributedString
    }

    var body: some View {
        HStack(alignment: .top, spacing: isCompact ? AppSpacing.small : AppSpacing.medium) {
            // Priority badge
            Circle()
                .fill(item.priority.color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)  // Align with first line of text
                .accessibilityLabel(item.priority.displayName + " priority")

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(attributedText)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(isExpanded ? nil : 2)
                    .font(isCompact ? .caption : .body)
                    .tint(AppColors.accent)

                // Show metadata only when expanded (and not in compact mode)
                if !isCompact && isExpanded {
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
            .animation(.easeInOut(duration: 0.3), value: isExpanded)

            Spacer()

            Button(action: onComplete) {
                Image(systemName: "checkmark.circle")
                    .font(isCompact ? .body : .title2)
                    .foregroundColor(AppColors.accent)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isCompact {
                isExpanded.toggle()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if !isCompact, let _ = onChangePriority {
                showPriorityPicker = true
            }
        }
        .confirmationDialog("Change Priority", isPresented: $showPriorityPicker) {
            ForEach([TodoPriority.urgent, .high, .normal, .low], id: \.self) { priority in
                Button(priority.displayName) {
                    onChangePriority?(priority)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Select a priority for this todo")
        }
        .padding(.vertical, isCompact ? AppSpacing.xSmall : AppSpacing.small)
        .listRowBackground(AppColors.surface)
        .contextMenu {
            if let onChangePriority = onChangePriority {
                // Priority submenu
                Menu("Priority") {
                    ForEach([TodoPriority.low, .normal, .high, .urgent], id: \.self) { priority in
                        Button(action: { onChangePriority(priority) }) {
                            HStack {
                                Text(priority.displayName)
                                if item.priority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }

                Divider()
            }

            Button("Mark Complete", action: onComplete)
            Button("Delete", role: .destructive, action: onDelete)
        }
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
        text: "Review pull request for new feature implementation\nhttps://github.com/example/repo/pull/123",
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
            onDelete: {},
            onChangePriority: { _ in }
        )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(AppColors.background)
}
