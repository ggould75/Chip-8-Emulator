//
//  ViewController.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func loadView() {
        let rect = NSRect(x: 0, y: 0, width: 500, height: 300)
        view = NSView(frame: rect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let chip8 = ObjectiveCppBridge()
        chip8.testLoadingRom()
    }
}
