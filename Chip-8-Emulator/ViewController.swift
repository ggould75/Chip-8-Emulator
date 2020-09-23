//
//  ViewController.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var chip8Bridge: Chip8Bridge?
    
    lazy var layerRenderer: Renderer = {
        return LayerRenderer()
    }()
    
    lazy var runningQueue = DispatchQueue(label: "com.chip8.running-queue")
    
    override func loadView() {
        let rect = NSRect(x: 0, y: 0, width: 500, height: 300)
        view = NSView(frame: rect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chip8Bridge = Chip8Bridge(screenRenderer: layerRenderer)
        chip8Bridge?.loadRom(withName: "tetris")
        
        runningQueue.async {
            self.chip8Bridge?.run()
        }
    }
}
