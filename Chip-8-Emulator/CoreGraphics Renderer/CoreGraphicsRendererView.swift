//
//  RendererView.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 15/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa
import CoreGraphics

final class CoreGraphicsRendererView: NSView {
    private let frameBufferSize: CGSize

    private static let maxDrawingBuffers = 2
    private let drawingBufferSize: Int
    private var drawingBuffers = [UnsafeMutablePointer<UInt8>]()
    private let drawingDispatchQueue = DispatchQueue(label: "com.chip8.drawing-queue")
    private let drawingDispatchSemaphore = DispatchSemaphore(value: maxDrawingBuffers)

    weak var keyboardHandler: KeyboardEventsHandler?
    
    override var isFlipped: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
    
    init(_ frameBufferSize: CGSize) {
        self.frameBufferSize = frameBufferSize
        self.drawingBufferSize = Int(frameBufferSize.width * frameBufferSize.height)
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        var drawingBuffer: UnsafeMutablePointer<UInt8>?
        drawingDispatchQueue.sync {
            drawingBuffer = drawingBuffers.first
        }

        guard
            let buffer = drawingBuffer,
            let context = NSGraphicsContext.current?.cgContext
        else {
            return
        }

        context.setFillColor(NSColor.black.cgColor)
        context.fill(dirtyRect)

        let squaresPath = CGMutablePath()
        context.setFillColor(NSColor.white.cgColor)

        let rectSize = dirtyRect.size
        let pixelSizeH = rectSize.width / frameBufferSize.width
        let pixelSizeV = rectSize.height / frameBufferSize.height

        for y in 0 ..< Int(frameBufferSize.height) {
            for x in 0 ..< Int(frameBufferSize.width) {
                let pixelIndex = x + y * Int(frameBufferSize.width)
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
        
        drawingDispatchQueue.sync {
            // At least one buffer should always exists, otherwise we can't redraw anything at the next pass.
            // This is especially necessary when a game end since draw operations will stop to be emitted
            if drawingBuffers.count > 1 {
                drawingBuffers.removeFirst()
                drawingBuffer?.deinitialize(count: drawingBufferSize)
                drawingBuffer?.deallocate()
                drawingBuffer = nil
            }
            
            // Since signal() increments the counting semaphore, we have to ensure we don't increment it if
            // we are already at max capacity, since this would cause a new buffer to be appended from draw(buffer:)
            // and go over the max capacity for the buffers. This can occur in particular if the window is
            // resized as resizing would cause draw() to be called repeatedly
            if drawingBuffers.count < Self.maxDrawingBuffers {
                drawingDispatchSemaphore.signal()
            } else {
                // If we are here it means that more buffers need to be consumed before we can let the emulator
                // producing new buffers. Scheduling a new redraw will consume the next buffer in the list.
                // This won't lead to a loop since we stop scheduling redraws as soon as all the required
                // buffers have been consumed. Note that eventually we are signaling the semaphore and
                // unblocking the emulator to produce new buffers; without it there are cases where the emulation
                // might stop due to redraw(buffer:) waiting and signal never invoked
                // (when switching to/from fullscreen for example)
                DispatchQueue.main.async {
                    self.needsDisplay = true
                }
            }
        }
    }
    
    // MARK: - NSResponder
    
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

extension CoreGraphicsRendererView: Renderer {
    func draw(buffer: UnsafePointer<UInt8>) {
        // We need some form of synchronization when processing the buffers produced by the emulator.
        // Without that, one buffer could be mutated by the emulator while being redrawn, or we could loose
        // buffers (frames) if NSView redraw is not scheduled at the right time.
        // We also have to ensure that we don't enqueue too many buffers otherwise the simulation will quickly go
        // out of sync with keyboard events, beeps (resizing would also consumes buffers too quickly and cause
        // weird issues). Note that this is not quite the same as double buffering.

        drawingDispatchSemaphore.wait()

        let bufferCopy = UnsafeMutablePointer<UInt8>.allocate(capacity: drawingBufferSize)
        bufferCopy.initialize(from: buffer, count: drawingBufferSize)
        
        drawingDispatchQueue.async {
            self.drawingBuffers.append(bufferCopy)

            DispatchQueue.main.async {
                self.needsDisplay = true
            }
        }
    }
}
