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
        setupMenuBar()

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

    private func setupMenuBar() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit Chip8 Emulator",
                                   action: #selector(NSApplication.terminate(_:)),
                                   keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // Speed menu
        let speedMenuItem = NSMenuItem()
        let speedMenu = NSMenu(title: "Speed")

        for preset in SpeedPresets.all {
            let item = NSMenuItem(title: preset.label,
                                  action: #selector(ViewController.selectSpeedPreset(_:)),
                                  keyEquivalent: "")
            item.tag = preset.value
            speedMenu.addItem(item)
        }

        speedMenu.addItem(.separator())

        let fasterItem = NSMenuItem(title: "Faster",
                                    action: #selector(ViewController.increaseSpeed(_:)),
                                    keyEquivalent: "+")
        fasterItem.keyEquivalentModifierMask = [.command]
        speedMenu.addItem(fasterItem)

        let slowerItem = NSMenuItem(title: "Slower",
                                    action: #selector(ViewController.decreaseSpeed(_:)),
                                    keyEquivalent: "-")
        slowerItem.keyEquivalentModifierMask = [.command]
        speedMenu.addItem(slowerItem)

        speedMenuItem.submenu = speedMenu
        mainMenu.addItem(speedMenuItem)

        NSApplication.shared.mainMenu = mainMenu
    }
}
