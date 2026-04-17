//
//  UserDefaultsPreferencesService.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation
import Combine

/// UserDefaults-based implementation of PreferencesService
@MainActor
final class UserDefaultsPreferencesService: PreferencesService {
    @Published private(set) var preferences: AppPreferences

    private let userDefaults: UserDefaults
    private let key = "com.todoshido.preferences"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.preferences = Self.loadPreferences(from: userDefaults, key: key)
    }

    func update(_ newPreferences: AppPreferences) throws {
        let data = try JSONEncoder().encode(newPreferences)
        userDefaults.set(data, forKey: key)
        preferences = newPreferences
        Logger.info("Preferences updated", category: "preferences")
    }

    func reset() {
        userDefaults.removeObject(forKey: key)
        preferences = .default
        Logger.info("Preferences reset to defaults", category: "preferences")
    }

    private static func loadPreferences(from userDefaults: UserDefaults, key: String) -> AppPreferences {
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(AppPreferences.self, from: data) else {
            Logger.debug("No preferences found, using defaults", category: "preferences")
            return .default
        }
        return decoded
    }
}
