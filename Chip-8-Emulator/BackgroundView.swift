//
//  BackgroundView.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 19/10/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa

class BackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedWhite: 0.8, alpha: 1.0).setFill()
        dirtyRect.fill()
    }
}
