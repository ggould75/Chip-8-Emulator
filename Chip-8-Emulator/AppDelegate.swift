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

        // Games menu
        let gamesMenuItem = NSMenuItem()
        let gamesMenu = NSMenu(title: "Games")

        let romURLs = Bundle.main.urls(forResourcesWithExtension: "rom", subdirectory: nil) ?? []
        let romNames = romURLs
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()

        for name in romNames {
            let item = NSMenuItem(title: name.capitalized,
                                  action: #selector(ViewController.selectGame(_:)),
                                  keyEquivalent: "")
            item.representedObject = name
            gamesMenu.addItem(item)
        }

        gamesMenu.addItem(.separator())

        let resetItem = NSMenuItem(title: "Reset",
                                   action: #selector(ViewController.resetGame(_:)),
                                   keyEquivalent: "r")
        resetItem.keyEquivalentModifierMask = [.command]
        gamesMenu.addItem(resetItem)

        gamesMenuItem.submenu = gamesMenu
        mainMenu.addItem(gamesMenuItem)

        // Play menu
        let playMenuItem = NSMenuItem()
        let playMenu = NSMenu(title: "Play")

        let pauseItem = NSMenuItem(title: "Pause",
                                   action: #selector(ViewController.togglePause(_:)),
                                   keyEquivalent: "p")
        pauseItem.keyEquivalentModifierMask = [.command]
        playMenu.addItem(pauseItem)

        // Speed submenu
        let speedSubMenuItem = NSMenuItem(title: "Speed", action: nil, keyEquivalent: "")
        let speedSubMenu = NSMenu(title: "Speed")

        for preset in SpeedPresets.all {
            let item = NSMenuItem(title: preset.label,
                                  action: #selector(ViewController.selectSpeedPreset(_:)),
                                  keyEquivalent: "")
            item.tag = preset.value
            speedSubMenu.addItem(item)
        }

        speedSubMenu.addItem(.separator())

        let fasterItem = NSMenuItem(title: "Faster",
                                    action: #selector(ViewController.increaseSpeed(_:)),
                                    keyEquivalent: "+")
        fasterItem.keyEquivalentModifierMask = [.command]
        speedSubMenu.addItem(fasterItem)

        let slowerItem = NSMenuItem(title: "Slower",
                                    action: #selector(ViewController.decreaseSpeed(_:)),
                                    keyEquivalent: "-")
        slowerItem.keyEquivalentModifierMask = [.command]
        speedSubMenu.addItem(slowerItem)

        speedSubMenuItem.submenu = speedSubMenu
        playMenu.addItem(speedSubMenuItem)

        playMenuItem.submenu = playMenu
        mainMenu.addItem(playMenuItem)

        NSApplication.shared.mainMenu = mainMenu
    }
}
