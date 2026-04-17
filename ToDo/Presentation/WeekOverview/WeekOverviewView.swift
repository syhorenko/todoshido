//
//  WeekOverviewView.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import SwiftUI

/// Week overview screen showing daily activity
struct WeekOverviewView: View {
    @StateObject var viewModel: WeekOverviewViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header with week navigation
            VStack(spacing: AppSpacing.small) {
                HStack {
                    Button(action: {
                        viewModel.previousWeek()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(AppColors.accent)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Week Overview")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)

                        Text(viewModel.currentWeek.displayString)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.nextWeek()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(AppColors.accent)
                    }
                    .buttonStyle(.plain)
                }

                // Today button
                if !viewModel.currentWeek.isCurrentWeek {
                    Button(action: {
                        viewModel.goToToday()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Today")
                        }
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.vertical, AppSpacing.xSmall)
                        .background(AppColors.elevated)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.medium)
            .background(AppColors.surface)

            Divider()

            // Content
            Group {
                if viewModel.isLoading && viewModel.dayActivities.isEmpty {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.dayActivities.isEmpty {
                    EmptyStateView(
                        title: "No Data",
                        message: "No activity for this week",
                        systemImage: "calendar"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.medium) {
                            ForEach(viewModel.dayActivities) { dayActivity in
                                DayActivityCard(dayActivity: dayActivity)
                            }
                        }
                        .padding(AppSpacing.medium)
                    }
                    .background(AppColors.background)
                }
            }
        }
        .background(AppColors.background)
        .navigationTitle("Week Overview")
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
        WeekOverviewView(
            viewModel: WeekOverviewViewModel(
                fetchWeekActivityUseCase: FetchWeekActivityUseCase(
                    repository: MockTodoRepository()
                )
            )
        )
    }
}
