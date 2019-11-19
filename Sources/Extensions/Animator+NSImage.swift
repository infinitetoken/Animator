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
    
    static func frames(from images: [NSImage], duration: Double = 1.0, background: NSColor = NSColor.black) -> [Frame] {
        return images.map({ (image) -> CGImage? in
            return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }).compactMap({ $0 }).map { (image) -> Frame in
            return Frame(image: image, duration: duration, background: background.cgColor)
        }
    }
    
}

public extension Animator.Frame {
    
    init?(image: NSImage, duration: Double, background: NSColor = NSColor.black) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        self.image = cgImage
        self.duration = duration
        self.background = background.cgColor
    }
    
}

#endif
