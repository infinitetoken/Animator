//
//  Animator.swift
//  Animator
//
//  Created by Aaron Wright on 7/16/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation
import UniformTypeIdentifiers

#if os(iOS) || os(tvOS)
import MobileCoreServices
#endif

public struct Animator {
    
    // MARK: - Enums
    
    public enum FileType {
        case apng
        case gif
    }
    
    // MARK: - Structs
    
    public struct Frame {
        var image: CGImage
        var duration: Double
        var background: CGColor
    }
    
}

// MARK: - Static Methods

extension Animator {
    
    public static func animation(from frames: [Frame], size: CGSize? = nil, type: FileType = .gif) async -> Data? {
        let width = frames.max { (a, b) -> Bool in
            return a.image.width < b.image.width
        }?.image.width ?? 0
        let height = frames.max { (a, b) -> Bool in
            return a.image.height < b.image.height
        }?.image.height ?? 0
        let size = size ?? CGSize(width: width, height: height)
        
        guard size.width > 0, size.height > 0 else { return nil }
        
        var fileProperties: [String : Any]
        var fileType: CFString
        
        switch type {
        case .apng:
            fileProperties = [
                kCGImagePropertyAPNGLoopCount as String : NSNumber(value: Int32(0) as Int32)
            ]
            fileType = kUTTypePNG
        case .gif:
            fileProperties = [
                kCGImagePropertyGIFLoopCount as String : NSNumber(value: Int32(0) as Int32),
                kCGImagePropertyGIFHasGlobalColorMap as String: NSValue(nonretainedObject: true)
            ]
            fileType = kUTTypeGIF
        }
        
        let data = NSMutableData()
        
        fileType = kUTTypePNG
        
        guard let destination = CGImageDestinationCreateWithData(data, fileType, frames.count, nil) else { return nil }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        var frameProperties: [String : Any]
        
        for frame in frames {
            switch type {
            case .apng:
                frameProperties = [
                    kCGImagePropertyAPNGDelayTime as String : frame.duration
                ]
            case .gif:
                frameProperties = [
                    kCGImagePropertyGIFDelayTime as String : frame.duration
                ]
            }
            
            CGImageDestinationAddImage(destination, frame.image, frameProperties as CFDictionary)
        }
        
        CGImageDestinationFinalize(destination)
        
        return data as Data
    }
    
    public static func frames(from images: [CGImage], duration: Double, background: CGColor) -> [Frame] {
        return images.map { (image) -> Frame in
            return Frame(image: image, duration: duration, background: background)
        }
    }
    
}
