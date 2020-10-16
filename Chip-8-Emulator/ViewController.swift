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
    lazy var runningQueue = DispatchQueue(label: "com.chip8.running-queue")
    
    override func loadView() {
        let rect = NSRect(x: 0, y: 0, width: 640, height: 320)
        view = NSView(frame: rect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(calibratedWhite: 0.8, alpha: 1.0).cgColor
        
        let viewRenderer = ViewRenderer()
        viewRenderer.keyboardHandler = self
        viewRenderer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewRenderer)
        
        NSLayoutConstraint.activate([
            viewRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewRenderer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            viewRenderer.heightAnchor.constraint(equalTo: viewRenderer.widthAnchor, multiplier: 0.5),
            viewRenderer.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
        ])
        
        chip8Bridge = Chip8Bridge(screenRenderer: viewRenderer)
        chip8Bridge?.loadRom(withName: "invaders")
        
        runningQueue.async {
            self.chip8Bridge?.run()
        }
    }
}

extension ViewController: KeyboardEventsHandler {
    func keyDownEvent(_ cChar: CChar) {
        chip8Bridge?.keyDownEvent(cChar)
    }
    
    func keyUpEvent(_ cChar: CChar) {
        chip8Bridge?.keyUpEvent(cChar)
    }
}
