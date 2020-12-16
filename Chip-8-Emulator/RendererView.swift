//
//  RendererView.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 15/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa
import CoreGraphics

@objc(C8Renderer)
protocol Renderer {
    func draw(buffer: UnsafePointer<UInt8>)
}

protocol KeyboardEventsHandler: class {
    func keyDownEvent(_ cChar: CChar)
    func keyUpEvent(_ cChar: CChar)
}

class RendererView: NSImageView {
    private let virtualMachineScreenSize: CGSize
    
//    private var drawingBuffer: UnsafePointer<UInt8>?
    private var drawingQueue = [UnsafeMutablePointer<UInt8>]()
    private let drawingDispatchQueue: DispatchQueue
//    private var renderedImage: NSImage?
    
    weak var keyboardHandler: KeyboardEventsHandler?
    
    override var isFlipped: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
    
    init(virtualMachineScreenSize: CGSize) {
        self.virtualMachineScreenSize = virtualMachineScreenSize
        self.drawingDispatchQueue = DispatchQueue(label: "com.chip8.drawing-queue")
        
        super.init(frame: .zero)
   
        self.imageScaling = .scaleProportionallyUpOrDown
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension RendererView: Renderer {
    func draw(buffer: UnsafePointer<UInt8>) {
        let size = Int(virtualMachineScreenSize.width * virtualMachineScreenSize.height)
        let bufferCopy = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        bufferCopy.initialize(from: buffer, count: size)

//        print("allocated \(bufferCopy) from \(buffer)")
        
        drawingDispatchQueue.async {
            self.drawingQueue.append(bufferCopy)
            
//            print("removing buffer (count: \(self.drawingQueue.count))")
            let drawingBuffer = self.drawingQueue.removeFirst()
//            print("dequeuedBuffer \(String(describing: drawingBuffer))")

            let colorSpace = CGColorSpace(name: CGColorSpace.linearGray)!
//            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

            let width = 640
            let height = 320
//            let width = 320
//            let height = 160
//            let width = 1280
//            let height = 640
            let retinaFactor = 2
            let scale = 10
            let ctx = CGContext(data: nil,
//                                width: width, height: height,
                                width: width * retinaFactor, height: height * retinaFactor,
                                bitsPerComponent: 8, bytesPerRow: 1280, //64x32
//                                bitsPerComponent: 16, bytesPerRow: 0, //1280x640
                                space: colorSpace,
//                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) //1280x640 - 16/0 - rgb
                                bitmapInfo: CGImageAlphaInfo.none.rawValue) // 8/0 - gray
//                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            //CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.floatComponents.rawValue  (32)

            guard let context = ctx else {
                return
            }

            context.translateBy(x: 0, y: CGFloat(height * retinaFactor))
            context.scaleBy(x: CGFloat(scale * retinaFactor), y: -CGFloat(scale * retinaFactor))
            
            
//            print("backingScaleFactor: \(String(describing: self.window?.backingScaleFactor)), bounds: \(self.bounds), ctm: \(context.ctm)")
            
//            print("ctm: \(context.ctm)")
//            print("userSpaceToDeviceSpaceTransform: \(context.userSpaceToDeviceSpaceTransform)")
            
            let squaresPath = CGMutablePath()
            context.setFillColor(NSColor.white.cgColor)

            let dirtyRect = CGRect(x: 0, y: 0, width: 64, height: 32)
            let rectSize = dirtyRect.size
            let pixelSizeH = rectSize.width / self.virtualMachineScreenSize.width
            let pixelSizeV = rectSize.height / self.virtualMachineScreenSize.height

            for y in 0 ..< Int(self.virtualMachineScreenSize.height) {
                for x in 0 ..< Int(self.virtualMachineScreenSize.width) {
                    let pixelIndex = x + y * Int(self.virtualMachineScreenSize.width)
                    let pixelValue = drawingBuffer[pixelIndex]
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

//            print("dealloc \(drawingBuffer)")
            drawingBuffer.deinitialize(count: size)
            drawingBuffer.deallocate()

            guard let renderedImage = ctx?.makeImage() else {
                return
            }

            DispatchQueue.main.async {
//                print("setting image")
//                self.image = NSImage(cgImage: renderedImage, size: .zero)
                self.image = NSImage(cgImage: renderedImage, size: CGSize(width: width, height: height))
            }
        }
    }
}
