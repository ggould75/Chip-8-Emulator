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
    func draw()
}

class LayerRenderer: CALayer {
    
}

extension LayerRenderer: Renderer {
    func draw() {
        
    }
}
