//
//  CGImage+Centered.swift
//  Animator
//
//  Created by Aaron Wright on 10/28/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

import Foundation
import CoreImage
import CoreGraphics

extension CGImage {
    
    func centered(in rect: CGRect, background: CGColor) -> CGImage? {
        let width = rect.size.width.integerValue
        let height = rect.size.height.integerValue

        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height

        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)

        let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        context?.setFillColor(background)
        context?.fill(rect)
        context?.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height).centered(in: rect))

        let image = context?.makeImage()

        pixelData.deallocate()

        return image
    }
    
}
