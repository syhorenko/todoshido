//
//  MockPreferencesService.swift
//  ToDo
//
//  Created by syh on 16/04/2026.
//

import Foundation
import Combine

/// In-memory implementation of PreferencesService for SwiftUI previews and testing
@MainActor
final class MockPreferencesService: ObservableObject, PreferencesService {
    @Published var preferences: AppPreferences = .default

    func update(_ preferences: AppPreferences) throws {
        self.preferences = preferences
    }

    func reset() {
        preferences = .default
    }
}
