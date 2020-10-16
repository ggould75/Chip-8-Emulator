//
//  AppDelegate.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSRect.zero,
                          styleMask: [.resizable, .closable, .titled],
                          backing: .buffered,
                          defer: false)
        window?.contentAspectRatio = CGSize(width: 2, height: 1)
        window?.title = "Chip8 Emulator"
        window?.makeKeyAndOrderFront(nil)
        
        let viewController = ViewController()
        window?.contentViewController = viewController
        
        let screenSize = NSScreen.main?.frame ?? NSRect.zero
        let windowSize = window?.frame ?? NSRect.zero
        let windowRect = NSRect(x: (screenSize.width - windowSize.width) / 2,
                                y: (screenSize.height - windowSize.height) / 2,
                                width: windowSize.width,
                                height: windowSize.height)
        window?.setFrame(windowRect, display: false)
    }
}
