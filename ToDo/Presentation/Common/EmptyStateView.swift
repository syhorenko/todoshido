//
//  EmptyStateView.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import SwiftUI

/// Reusable empty state view for lists
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(AppColors.secondaryText)

            VStack(spacing: AppSpacing.small) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.xxLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    EmptyStateView(
        title: "No Items",
        message: "There are no items to display",
        systemImage: "tray"
    )
}
