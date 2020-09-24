//
//  DrawingLayer.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 15/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

import Cocoa

@objc(CERenderer)
protocol Renderer {
    func draw(buffer: UnsafePointer<UInt8>)
}

class LayerRenderer: CALayer {

}

extension LayerRenderer: Renderer {
    func draw(buffer: UnsafePointer<UInt8>) {
        for y in 0 ..< 32 {
            for x in 0 ..< 64 {
                let pixelIndex = x + y * 64
                let pixelValue = buffer[pixelIndex]
                if pixelValue > 0 {
                    // TODO: draw pixel at (x,y)
                }
            }
        }
    }
}
