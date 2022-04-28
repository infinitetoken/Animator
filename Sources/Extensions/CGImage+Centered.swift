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
        
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.setShouldAntialias(false)
        context?.interpolationQuality = .none
        context?.setFillColor(background)
        context?.fill(rect)
        context?.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height).centered(in: rect))

        return context?.makeImage()
    }
    
}
