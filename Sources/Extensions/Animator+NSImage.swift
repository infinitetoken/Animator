//
//  Animator+NSImage.swift
//  Animator
//
//  Created by Aaron Wright on 7/31/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

#if os(macOS)

import Cocoa

public extension Animator {
    
    static func frames(from images: [NSImage], duration: Double = 1.0) -> [Frame] {
        return images.map({ (image) -> CGImage? in
            return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }).compactMap({ $0 }).map { (image) -> Frame in
            return Frame(image: image, duration: duration)
        }
    }
    
}

public extension Animator.Frame {
    
    init?(image: NSImage, duration: Double) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        self.image = cgImage
        self.duration = duration
    }
    
}

#endif
