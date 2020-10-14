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
    func keyboardKeyDidPress(cChar: Int8)
}

class ViewRenderer: NSView {
    static let pixelSize = 6
    var drawingBuffer: UnsafePointer<UInt8>?
    
    weak var keyboardHandler: KeyboardEventsHandler?
    
    override var isFlipped: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let buffer = drawingBuffer else {
            print("Empty buffer!")
            return
        }
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        context.setFillColor(NSColor.black.cgColor)
        context.fill(dirtyRect)
        
        let squaresPath = CGMutablePath()
        context.setFillColor(NSColor.white.cgColor)
        
        let pixelSize = ViewRenderer.pixelSize
        for y in 0 ..< 32 {
            for x in 0 ..< 64 {
                let pixelIndex = x + y * 64
                let pixelValue = buffer[pixelIndex]
                if pixelValue > 0 {
                    let rect = CGRect(x: pixelSize * x,
                                      y: pixelSize * y,
                                      width: pixelSize,
                                      height: pixelSize)
                    squaresPath.addRect(rect)
                }
            }
        }
        
        context.addPath(squaresPath)
        context.drawPath(using: .fill)
    }
    
    override func keyDown(with event: NSEvent) {
        guard let firstChar = event.characters?.first else {
            super.keyDown(with: event)
            return
        }
        
        let cCharPointer = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
        String(firstChar).withCString { unsafePointerInt8 in
            cCharPointer.initialize(from: unsafePointerInt8, count: 1)
        }
        let cChar = cCharPointer.pointee
        cCharPointer.deallocate()
        
        keyboardHandler?.keyboardKeyDidPress(cChar: cChar)
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
