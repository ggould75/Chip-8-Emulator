//
//  SpeedPresets.swift
//  Chip-8-Emulator
//

import Foundation

struct SpeedPreset {
    let label: String
    let value: Int
}

struct SpeedPresets {
    static let all: [SpeedPreset] = [
        SpeedPreset(label: "5 — Slowest",  value: 5),
        SpeedPreset(label: "8 — Slow",     value: 8),
        SpeedPreset(label: "10",           value: 10),
        SpeedPreset(label: "15 — Default", value: 15),
        SpeedPreset(label: "20",           value: 20),
        SpeedPreset(label: "30 — Fast",    value: 30),
        SpeedPreset(label: "50 — Fastest", value: 50),
    ]

    static let defaultValue = 15

    static func index(of value: Int) -> Int? {
        all.firstIndex(where: { $0.value == value })
    }
}
