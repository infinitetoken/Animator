//
//  Animator+NSImage.swift
//  Animator
//
//  Created by Aaron Wright on 7/31/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

#if os(macOS)

import Cocoa

public extension Animator.Frame {
    
    init?(image: NSImage, duration: Double, position: Int = 0, background: NSColor = NSColor.black) {
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        guard let cgImage = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
            return nil
        }
        
        self.image = cgImage
        self.duration = duration
        self.position = position
        self.background = background.cgColor
    }
    
}

#endif
