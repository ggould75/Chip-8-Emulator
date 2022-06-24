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

    private static let vmScreenSize = CGSize(width: 64, height: 32)
    private static let windowRect = CGRect(x: 0, y: 0, width: 640, height: 320)
    
    private enum RendererType {
        case coreGraphics
        case metal
    }
    
    // Change this property to test the other renderer
    private let rendererType: RendererType = .metal
    
    private lazy var rendererView: NSView = {
        let view: NSView
        switch rendererType {
        case .coreGraphics:
            let cgView = CoreGraphicsRendererView(Self.vmScreenSize)
            cgView.keyboardHandler = self
            cgView.layer?.drawsAsynchronously = true
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
        guard cppBridge?.loadRom(withName: "brix") == true else {
            showAlertWithMessage("Unable to find the ROM image.")
            return
        }

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
