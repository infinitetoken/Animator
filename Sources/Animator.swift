//
//  Animator.swift
//  Animator
//
//  Created by Aaron Wright on 7/16/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreVideo
import AVFoundation

#if os(iOS) || os(tvOS)
import MobileCoreServices
#endif

public struct Animator {
    
    public enum AnimatorError: LocalizedError {
        case failed
        case error(Error)
        
        public var errorDescription: String? {
            switch self {
            case .failed:
                return "Failed"
            case .error(let error):
                return error.localizedDescription
            }
        }
    }
    
    public struct Frame {
        var image: CGImage
        var duration: Double
        var background: CGColor
    }
    
    public static func movie(from frames: [Frame], outputURL: URL, size: CGSize? = nil, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        var assetWriter: AVAssetWriter
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: outputURL.path) {
            do {
                try fileManager.removeItem(at: outputURL)
            } catch {
                completion(AnimatorError.error(error))
                return
            }
        }
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        } catch {
            completion(AnimatorError.error(error))
            return
        }
        
        let width = frames.max { (a, b) -> Bool in
            return a.image.width < b.image.width
        }?.image.width ?? 0
        let height = frames.max { (a, b) -> Bool in
            return a.image.height < b.image.height
        }?.image.height ?? 0
        let size = size ?? CGSize(width: width, height: height)
        
        guard size.width > 0, size.height > 0 else {
            completion(AnimatorError.failed)
            return
        }
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: settings)
        let attributes: [String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: attributes)
        
        assetWriter.add(assetWriterInput)
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        var frameIndex: Int = 0
        var frameTime: Double = 0.0
        
        assetWriterInput.requestMediaDataWhenReady(on: queue) {
            while assetWriterInput.isReadyForMoreMediaData && frameIndex < frames.count {
                let frame = frames[frameIndex]
                
                if let image = frame.image.centered(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), background: frame.background), let buffer = image.pixelBuffer(size: size) {
                    adaptor.append(buffer, withPresentationTime: CMTime(seconds: frameTime, preferredTimescale: 1000))
                    
                    frameTime += frame.duration
                }
                frameIndex += 1
            }
            
            assetWriterInput.markAsFinished()
            
            assetWriter.finishWriting {
                if let error = assetWriter.error {
                    DispatchQueue.main.async { completion(AnimatorError.error(error)) }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }
    }
    
    public static func animation(from frames: [Frame], outputURL: URL, size: CGSize? = nil, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        let width = frames.max { (a, b) -> Bool in
            return a.image.width < b.image.width
        }?.image.width ?? 0
        let height = frames.max { (a, b) -> Bool in
            return a.image.height < b.image.height
        }?.image.height ?? 0
        let size = size ?? CGSize(width: width, height: height)
        
        guard size.width > 0, size.height > 0 else {
            completion(AnimatorError.failed)
            return
        }
        
        queue.async {
            let fileProperties = [kCGImagePropertyGIFDictionary as String:[
                kCGImagePropertyGIFLoopCount as String: NSNumber(value: Int32(0) as Int32)],
                kCGImagePropertyGIFHasGlobalColorMap as String: NSValue(nonretainedObject: true)
            ] as [String : Any]
            
            guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, kUTTypeGIF, frames.count, nil) else {
                DispatchQueue.main.async { completion(AnimatorError.failed) }
                return
            }
            
            CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
            
            for frame in frames {
                let frameProperties = [
                    kCGImagePropertyGIFDictionary as String:[
                        kCGImagePropertyGIFDelayTime as String: frame.duration
                    ]
                ]
                
                if let image = frame.image.centered(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), background: frame.background) {
                    CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
                }
            }
            
            if CGImageDestinationFinalize(destination) {
                DispatchQueue.main.async { completion(nil) }
            } else {
                DispatchQueue.main.async { completion(AnimatorError.failed) }
            }
        }
    }
    
}

public extension Animator {
    
    static func frames(from images: [CGImage], duration: Double, background: CGColor) -> [Frame] {
        return images.map { (image) -> Frame in
            return Frame(image: image, duration: duration, background: background)
        }
    }
    
}
