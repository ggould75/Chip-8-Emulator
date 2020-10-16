//
//  DrawingLayer.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 15/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa
import CoreGraphics

@objc(CERenderer)
protocol Renderer {
    func draw(buffer: UnsafePointer<UInt8>)
}

protocol KeyboardEventsHandler: class {
    func keyDownEvent(_ cChar: CChar)
    func keyUpEvent(_ cChar: CChar)
}

class ViewRenderer: NSView {
    let virtualMachineScreenSize: CGSize
    
    var drawingBuffer: UnsafePointer<UInt8>?
    
    weak var keyboardHandler: KeyboardEventsHandler?
    
    override var isFlipped: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
    
    init(virtualMachineScreenSize: CGSize) {
        self.virtualMachineScreenSize = virtualMachineScreenSize
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let buffer = drawingBuffer else {
            return
        }
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        context.setFillColor(NSColor.black.cgColor)
        context.fill(dirtyRect)
        
        let squaresPath = CGMutablePath()
        context.setFillColor(NSColor.white.cgColor)
        
        let rectSize = dirtyRect.size
        let pixelSizeH = rectSize.width / virtualMachineScreenSize.width
        let pixelSizeV = rectSize.height / virtualMachineScreenSize.height
        
        for y in 0 ..< Int(virtualMachineScreenSize.height) {
            for x in 0 ..< Int(virtualMachineScreenSize.width) {
                let pixelIndex = x + y * Int(virtualMachineScreenSize.width)
                let pixelValue = buffer[pixelIndex]
                if pixelValue > 0 {
                    let rect = CGRect(x: pixelSizeH * CGFloat(x),
                                      y: pixelSizeV * CGFloat(y),
                                      width: pixelSizeH,
                                      height: pixelSizeV)
                    squaresPath.addRect(rect)
                }
            }
        }
        
        context.addPath(squaresPath)
        context.drawPath(using: .fill)
    }
    
    override func keyDown(with event: NSEvent) {
        guard let firstChar = event.characters?.lowercased().first,
              let asciiValue = firstChar.asciiValue
        else {
            super.keyDown(with: event)
            return
        }
        
        keyboardHandler?.keyDownEvent(Int8(asciiValue))
    }
    
    override func keyUp(with event: NSEvent) {
        guard let firstChar = event.characters?.lowercased().first,
              let asciiValue = firstChar.asciiValue
        else {
            super.keyUp(with: event)
            return
        }
        
        keyboardHandler?.keyUpEvent(Int8(asciiValue))
    }
}

extension ViewRenderer: Renderer {
    func draw(buffer: UnsafePointer<UInt8>) {
        drawingBuffer = buffer
        
        DispatchQueue.main.async {
            self.needsDisplay = true
        }
    }
}
