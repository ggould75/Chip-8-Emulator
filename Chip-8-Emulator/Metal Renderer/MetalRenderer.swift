//
//  MetalRenderer.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 20/06/2022.
//  Copyright © 2022 Marco Mussini. All rights reserved.
//

import Metal
import MetalKit

enum MetalRendererError: Error {
    case couldNotBuildCommandQueue
    case couldNotBuildBuffer
}

final class MetalRenderer {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState?
    private var vertexPositionsBuffer: MTLBuffer?
    private var currentTexture: MTLTexture?
    
    private let frameBufferSize: CGSize

    init(_ frameBufferSize: CGSize, _ device: MTLDevice) throws {
        self.device = device
        self.frameBufferSize = frameBufferSize

        guard let commandQueue = device.makeCommandQueue() else {
            throw MetalRendererError.couldNotBuildCommandQueue
        }
        
        self.commandQueue = commandQueue

        self.renderPipelineState = try makeRenderPipelineState()

        guard let vertexPositionsBuffer = makeBuffer() else {
            throw MetalRendererError.couldNotBuildBuffer
        }
        
        self.vertexPositionsBuffer = vertexPositionsBuffer
    }
    
    private func makeRenderPipelineState() throws -> MTLRenderPipelineState {
        let library = try device.makeDefaultLibrary(bundle: Bundle.main)
        
        let vertexFn = library.makeFunction(name: "vertexMain")
        let fragmentFn = library.makeFunction(name: "fragmentMainNearest")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFn
        pipelineDescriptor.fragmentFunction = fragmentFn
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func makeBuffer() -> MTLBuffer? {
        let positions: [ScreenVertex] = [
            ScreenVertex(position: vector_float2(-1,  1), textureCoordinate: vector_float2(0, 0)),
            ScreenVertex(position: vector_float2( 1,  1), textureCoordinate: vector_float2(1, 0)),
            ScreenVertex(position: vector_float2(-1, -1), textureCoordinate: vector_float2(0, 1)),
            ScreenVertex(position: vector_float2( 1, -1), textureCoordinate: vector_float2(1, 1))
        ]

        let positionsSize = positions.count * MemoryLayout<ScreenVertex>.size
        guard let positionsBuffer = device.makeBuffer(length: positionsSize, options: .storageModeManaged) else {
            return nil
        }
        
        memcpy(positionsBuffer.contents(), positions, positionsSize)
        positionsBuffer.didModifyRange(0..<positionsBuffer.length)
        
        return positionsBuffer
    }
    
    private func updateTexture(from buffer: UnsafePointer<UInt8>) {
        let frameBufferWidth = Int(frameBufferSize.width)
        let frameBufferHeight = Int(frameBufferSize.height)
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = frameBufferWidth
        textureDescriptor.height = frameBufferHeight
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.textureType = .type2D
        textureDescriptor.storageMode = .managed
        textureDescriptor.usage = .shaderRead

        currentTexture = device.makeTexture(descriptor: textureDescriptor)
        
        // PixelFormatRGBA8Unorm requires 4 Bytes per pixel
        let textureData = UnsafeMutableRawPointer.allocate(byteCount: frameBufferWidth * frameBufferHeight * 4,
                                                           alignment: MemoryLayout<UInt8>.alignment)
        for y in 0 ..< frameBufferHeight {
            for x in 0 ..< frameBufferWidth {
                let pixelIndex = x + y * frameBufferWidth
                let pixelValue: UInt8 = buffer[pixelIndex] > 0 ? 0xFF : 0x0

                textureData.storeBytes(of: pixelValue, toByteOffset: pixelIndex * 4 + 0, as: UInt8.self)
                textureData.storeBytes(of: pixelValue, toByteOffset: pixelIndex * 4 + 1, as: UInt8.self)
                textureData.storeBytes(of: pixelValue, toByteOffset: pixelIndex * 4 + 2, as: UInt8.self)
                textureData.storeBytes(of: 0xFF,       toByteOffset: pixelIndex * 4 + 3, as: UInt8.self)
            }
        }
        
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                               size: MTLSize(width: frameBufferWidth, height: frameBufferHeight, depth: 1))
        currentTexture?.replace(region: region, mipmapLevel: 0, withBytes: textureData, bytesPerRow: frameBufferWidth * 4)
        
        textureData.deallocate()
    }
    
    func draw(_ buffer: UnsafePointer<UInt8>, in view: MTKView) {
        guard
            let passDescriptor = view.currentRenderPassDescriptor,
            let currentDrawable = view.currentDrawable,
            let renderPipelineState = renderPipelineState,
            let command = commandQueue.makeCommandBuffer(),
            let commandEncoder = command.makeRenderCommandEncoder(descriptor: passDescriptor)
        else {
            assertionFailure("Missing parameters for drawing with Metal")
            return
        }
        
        updateTexture(from: buffer)
        
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexPositionsBuffer, offset: 0, index: 0)
        commandEncoder.setFragmentTexture(currentTexture, index: 0)
        
        commandEncoder.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 4)

        commandEncoder.endEncoding()
        
        command.present(currentDrawable)
        command.commit()
        
        view.draw()
    }
}
