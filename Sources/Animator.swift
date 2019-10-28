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
        var fillColor: CGColor = CGColor.black
    }
    
    public static func movie(from frames: [Frame], outputURL: URL, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        var assetWriter: AVAssetWriter
        
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
        let size = CGSize(width: width, height: height)
        
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
                
                if let image = frame.image.centered(in: CGRect(x: 0, y: 0, width: width, height: height), fillColor: frame.fillColor), let buffer = image.pixelBuffer(size: size) {
                    adaptor.append(buffer, withPresentationTime: CMTime(seconds: frameTime, preferredTimescale: 1))
                    
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
    
    public static func animation(from frames: [Frame], outputURL: URL, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        let width = frames.max { (a, b) -> Bool in
            return a.image.width < b.image.width
        }?.image.width ?? 0
        let height = frames.max { (a, b) -> Bool in
            return a.image.height < b.image.height
        }?.image.height ?? 0
        
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
                
                if let image = frame.image.centered(in: CGRect(x: 0, y: 0, width: width, height: height), fillColor: frame.fillColor) {
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
    
    static func frames(from images: [CGImage], duration: Double = 3.0) -> [Frame] {
        return images.map { (image) -> Frame in
            return Frame(image: image, duration: duration)
        }
    }
    
}
