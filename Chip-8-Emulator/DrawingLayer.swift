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

class ViewRenderer: NSView {
    static let pixelSize = 6
    var drawingBuffer: UnsafePointer<UInt8>?
    override var isFlipped: Bool { return true }
}

extension ViewRenderer: Renderer {
    func draw(buffer: UnsafePointer<UInt8>) {
        drawingBuffer = buffer
        
        DispatchQueue.main.async {
            self.needsDisplay = true
        }
    }
    
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
                
        for y in 0 ..< 32 {
            for x in 0 ..< 64 {
                let pixelIndex = x + y * 64
                let pixelValue = buffer[pixelIndex]
                if pixelValue > 0 {
                    let rect = CGRect(x: ViewRenderer.pixelSize * x,
                                      y: ViewRenderer.pixelSize * y,
                                      width: ViewRenderer.pixelSize,
                                      height: ViewRenderer.pixelSize)
                    squaresPath.addRect(rect)
                }
            }
        }
        
        context.addPath(squaresPath)
        context.drawPath(using: .fill)
    }
}
