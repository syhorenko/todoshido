//
//  SoundService.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation
import AppKit

/// Protocol for playing system sounds
protocol SoundService {
    func playTaskCreated()
    func playTaskCompleted()
}

/// macOS implementation using NSSound
final class NSSoundService: SoundService {
    func playTaskCreated() {
        NSSound(named: .init("Tink"))?.play()
    }

    func playTaskCompleted() {
        NSSound(named: .init("Hero"))?.play()
    }
}
