//
//  Renderer.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 19/06/2022.
//  Copyright © 2022 Marco Mussini. All rights reserved.
//

@objc(C8Renderer)
protocol Renderer {
    func draw(buffer: UnsafePointer<UInt8>)
}
