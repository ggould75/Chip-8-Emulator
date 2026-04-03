//
//  ViewController.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
    private var cppBridge: SwiftCppBridge?
    private lazy var runningQueue = DispatchQueue(label: "com.chip8.running-queue")
    private var currentSpeedIndex: Int = SpeedPresets.index(of: SpeedPresets.defaultValue) ?? 3
    private var currentGameName: String = ""

    private static let vmScreenSize = CGSize(width: 64, height: 32)
    private static let windowRect = CGRect(x: 0, y: 0, width: 640, height: 320)
    
    private enum RendererType {
        case coreGraphics
        case metal
    }
    
    // Change this property to test the other renderer
    private let rendererType: RendererType = .coreGraphics
    
    private lazy var rendererView: NSView = {
        let view: NSView
        switch rendererType {
        case .coreGraphics:
            let cgView = CoreGraphicsRendererView(Self.vmScreenSize)
            cgView.keyboardHandler = self
            view = cgView
            
        case .metal:
            guard let device = MTLCreateSystemDefaultDevice() else {
                fatalError("Unable to create the Metal device")
            }

            let metalRenderer: MetalRenderer
            do {
                metalRenderer = try MetalRenderer(Self.vmScreenSize, device)
            } catch {
                fatalError("Unable to instantiate the Metal renderer: \(error)")
            }
            
            let metalView = MetalView(frame: Self.windowRect, device, metalRenderer)
            metalView.keyboardHandler = self
            metalView.colorPixelFormat = .bgra8Unorm
            metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
            metalView.isPaused = true
            metalView.enableSetNeedsDisplay = false
            view = metalView
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func loadView() {
        view = BackgroundView(frame: Self.windowRect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(rendererView)
        
        NSLayoutConstraint.activate([
            rendererView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rendererView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rendererView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rendererView.heightAnchor.constraint(equalTo: rendererView.widthAnchor, multiplier: 0.5),
            rendererView.widthAnchor.constraint(greaterThanOrEqualToConstant: Self.vmScreenSize.width),
        ])
        
        guard let rendererView = rendererView as? Renderer else {
            print("Renderer view doesn't conform to the required protocol.")
            return
        }
        
        cppBridge = SwiftCppBridge(screenRenderer: rendererView)
        loadGame("brix")
    }

    private func loadGame(_ name: String) {
        cppBridge?.stop()
        cppBridge?.reset()

        guard cppBridge?.loadRom(withName: name) == true else {
            showAlertWithMessage("Unable to find the ROM image.")
            return
        }

        currentGameName = name

        runningQueue.async {
            self.cppBridge?.run()
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
        cppBridge?.keyDownEvent(cChar)
    }
    
    func keyUpEvent(_ cChar: CChar) {
        cppBridge?.keyUpEvent(cChar)
    }
}

// MARK: - Games menu actions

extension ViewController {
    @objc func selectGame(_ sender: NSMenuItem) {
        guard let name = sender.representedObject as? String else { return }
        loadGame(name)
    }

    @objc func resetGame(_ sender: NSMenuItem) {
        loadGame(currentGameName)
    }
}

// MARK: - Play menu actions

extension ViewController: NSMenuItemValidation {
    @objc func togglePause(_ sender: NSMenuItem) {
        guard let bridge = cppBridge else { return }
        bridge.setPaused(!bridge.isPaused())
    }

    @objc func selectSpeedPreset(_ sender: NSMenuItem) {
        guard let index = SpeedPresets.index(of: sender.tag) else { return }
        currentSpeedIndex = index
        applySpeed(SpeedPresets.all[index].value)
    }

    @objc func increaseSpeed(_ sender: NSMenuItem) {
        guard currentSpeedIndex < SpeedPresets.all.count - 1 else { return }
        currentSpeedIndex += 1
        applySpeed(SpeedPresets.all[currentSpeedIndex].value)
    }

    @objc func decreaseSpeed(_ sender: NSMenuItem) {
        guard currentSpeedIndex > 0 else { return }
        currentSpeedIndex -= 1
        applySpeed(SpeedPresets.all[currentSpeedIndex].value)
    }

    private func applySpeed(_ value: Int) {
        cppBridge?.setInstructionsPerFrame(Int32(value))
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(togglePause(_:)) {
            let paused = cppBridge?.isPaused() ?? false
            menuItem.title = paused ? "Resume" : "Pause"
            return true
        }
        if menuItem.action == #selector(resetGame(_:)) {
            return !currentGameName.isEmpty
        }
        if menuItem.action == #selector(selectGame(_:)) {
            let name = menuItem.representedObject as? String ?? ""
            menuItem.state = name == currentGameName ? .on : .off
            return true
        }
        if menuItem.action == #selector(selectSpeedPreset(_:)) {
            let currentValue = SpeedPresets.all[currentSpeedIndex].value
            menuItem.state = menuItem.tag == currentValue ? .on : .off
            return true
        }
        if menuItem.action == #selector(increaseSpeed(_:)) {
            return currentSpeedIndex < SpeedPresets.all.count - 1
        }
        if menuItem.action == #selector(decreaseSpeed(_:)) {
            return currentSpeedIndex > 0
        }
        return true
    }
}
