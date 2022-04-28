//
//  CGImage+CVPixelBuffer.swift
//  Animator
//
//  Created by Aaron Wright on 10/28/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreVideo

extension CGImage {
    
    public func pixelBuffer(size: CGSize) -> CVPixelBuffer? {
        return pixelBuffer(
            size: size,
            pixelFormatType: kCVPixelFormatType_32RGBA,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            alphaInfo: .last
        )
    }
    
    func pixelBuffer(size: CGSize, pixelFormatType: OSType, colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
        var buffer: CVPixelBuffer?
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            size.width.integerValue,
            size.height.integerValue,
            pixelFormatType,
            attrs as CFDictionary,
            &buffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer = buffer else {
            return nil
        }

        let flags = CVPixelBufferLockFlags(rawValue: 0)
        guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
            return nil
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: size.width.integerValue,
            height: size.height.integerValue,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: colorSpace,
            bitmapInfo: alphaInfo.rawValue
        ) else {
            return nil
        }
        context.setShouldAntialias(false)
        context.interpolationQuality = .none
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        
        return pixelBuffer
    }
    
}
