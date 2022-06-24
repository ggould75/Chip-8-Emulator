//
//  MetalView.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 19/06/2022.
//  Copyright © 2022 Marco Mussini. All rights reserved.
//

import Cocoa
import MetalKit

final class MetalView: MTKView {
    let metalRenderer: MetalRenderer
    
    weak var keyboardHandler: KeyboardEventsHandler?
    
    override var isFlipped: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
  
    init(frame frameRect: CGRect, _ device: MTLDevice, _ metalRenderer: MetalRenderer) {
        self.metalRenderer = metalRenderer
        
        super.init(frame: frameRect, device: device)
    }
        
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension MetalView: Renderer {
    func draw(buffer: UnsafePointer<UInt8>) {
        metalRenderer.draw(buffer, in: self)
    }
}
