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
        let rect = NSRect(x: 0, y: 0, width: 500, height: 300)
        view = NSView(frame: rect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewRenderer = ViewRenderer()
        viewRenderer.keyboardHandler = self
        viewRenderer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewRenderer)
        
        NSLayoutConstraint.activate([
            viewRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewRenderer.topAnchor.constraint(equalTo: view.topAnchor),
            viewRenderer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
