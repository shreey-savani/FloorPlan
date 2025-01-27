//
//  creatT.swift
//  floorplan
//
//  Created by teqnodux on 27/01/25.
//

import Foundation
import Metal
import AVFoundation
import ARKit
import RealityKit
import MetalKit


func createTexture(from pixelBuffer: CVPixelBuffer, device: MTLDevice) -> MTLTexture? {
    // Create a Metal texture from the pixel buffer
    let textureLoader = MTKTextureLoader(device: device)
    
    // Create a CIImage from the pixel buffer
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    
    do {
        let texture = try textureLoader.newTexture(cgImage: ciImage.cgImage!)
        return texture
    } catch {
        print("Error creating Metal texture: \(error)")
        return nil
    }
}
