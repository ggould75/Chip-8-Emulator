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
        view = BackgroundView(frame: rect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vmScreenSize = CGSize(width: 64, height: 32)
        let viewRenderer = RendererView(virtualMachineScreenSize: vmScreenSize)
        viewRenderer.layer?.drawsAsynchronously = true
        viewRenderer.keyboardHandler = self
        viewRenderer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewRenderer)
        
        NSLayoutConstraint.activate([
            viewRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewRenderer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            viewRenderer.heightAnchor.constraint(equalTo: viewRenderer.widthAnchor, multiplier: 0.5),
            viewRenderer.widthAnchor.constraint(greaterThanOrEqualToConstant: vmScreenSize.width),
        ])
        
        chip8Bridge = Chip8Bridge(screenRenderer: viewRenderer)
        guard chip8Bridge?.loadRom(withName: "pong2") == true else {
            showAlertWithMessage("Unable to find the ROM image.")
            return
        }

        runningQueue.async {
            self.chip8Bridge?.run()
        }
    }
    
    private func showAlertWithMessage(_ msg: String) {
        guard let window = NSApp.mainWindow else { return }
        
        let alert = NSAlert()
        alert.messageText = msg
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window, completionHandler: nil)
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
