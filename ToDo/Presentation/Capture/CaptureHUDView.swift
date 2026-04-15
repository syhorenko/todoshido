//
//  CaptureHUDView.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// Transient HUD overlay for capture feedback
struct CaptureHUDView: View {
    let message: String
    let type: CaptureResultType

    enum CaptureResultType {
        case success
        case error
    }

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title2)

            Text(message)
                .foregroundColor(AppColors.primaryText)
                .font(.body)
                .lineLimit(2)
        }
        .padding(AppSpacing.medium)
        .background(AppColors.elevated)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
    }

    private var icon: String {
        type == .success ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }

    private var iconColor: Color {
        type == .success ? .green : .red
    }
}

#Preview {
    VStack(spacing: AppSpacing.large) {
        CaptureHUDView(
            message: "Captured: Review pull request for new feature",
            type: .success
        )

        CaptureHUDView(
            message: "Clipboard is empty",
            type: .error
        )
    }
    .padding()
    .background(AppColors.background)
}
