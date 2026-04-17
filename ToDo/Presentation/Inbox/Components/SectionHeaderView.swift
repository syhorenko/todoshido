//
//  SectionHeaderView.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import SwiftUI

/// Section header view for grouped todo lists
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.secondaryText)
            .textCase(.uppercase)
            .padding(.top, AppSpacing.small)
    }
}

#Preview {
    VStack(spacing: 0) {
        SectionHeaderView(title: "Today")
        SectionHeaderView(title: "Yesterday")
        SectionHeaderView(title: "Monday, April 15, 2026")
    }
    .background(AppColors.background)
}
