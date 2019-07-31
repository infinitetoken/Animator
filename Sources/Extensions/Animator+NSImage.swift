//
//  File.swift
//  
//
//  Created by Aaron Wright on 7/31/19.
//

#if os(macOS)

import Cocoa

public extension Animator {
    
    static func frames(from images: [NSImage], duration: Double = 1.0) -> [Frame] {
        return images.map({ (image) -> CGImage? in
            var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            
            return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        }).compactMap({ $0 }).map { (image) -> Frame in
            return Frame(image: image, duration: duration)
        }
    }
    
}

public extension Animator.Frame {
    
    init?(image: NSImage, duration: Double) {
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        guard let cgImage = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
            return nil
        }
        
        self.image = cgImage
        self.duration = duration
    }
    
}

#endif
