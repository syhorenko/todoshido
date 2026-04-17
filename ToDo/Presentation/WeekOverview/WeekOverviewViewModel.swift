//
//  WeekOverviewViewModel.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for Week Overview screen
@MainActor
final class WeekOverviewViewModel: ObservableObject {
    @Published var currentWeek: WeekRange
    @Published var dayActivities: [DayActivity] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchWeekActivityUseCase: FetchWeekActivityUseCase

    init(fetchWeekActivityUseCase: FetchWeekActivityUseCase) {
        self.fetchWeekActivityUseCase = fetchWeekActivityUseCase
        self.currentWeek = WeekRange.currentWeek()
    }

    /// Load activity for the current week
    func load() async {
        isLoading = true
        error = nil

        do {
            dayActivities = try await fetchWeekActivityUseCase.execute(for: currentWeek)
            Logger.info("Loaded week activity: \(dayActivities.count) days", category: "weekoverview")
        } catch {
            self.error = error
            Logger.error("Failed to load week activity: \(error)", category: "weekoverview")
        }

        isLoading = false
    }

    /// Navigate to the previous week
    func previousWeek() {
        currentWeek = currentWeek.previousWeek()
        Task {
            await load()
        }
    }

    /// Navigate to the next week
    func nextWeek() {
        currentWeek = currentWeek.nextWeek()
        Task {
            await load()
        }
    }

    /// Jump to the current week
    func goToToday() {
        currentWeek = WeekRange.currentWeek()
        Task {
            await load()
        }
    }
}
