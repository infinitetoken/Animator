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
    }
    
    public static func movie(from frames: [Frame], size: CGSize, outputURL: URL, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        var assetWriter: AVAssetWriter
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        } catch {
            completion(AnimatorError.error(error))
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
        
        assetWriterInput.requestMediaDataWhenReady(on: queue) {
            var seconds: Double = 0.0
            
            for frame in frames {
                while !assetWriterInput.isReadyForMoreMediaData { usleep(10) }
                
                if let buffer = self.pixelBuffer(fromImage: frame.image, size: size, attributes: attributes) {
                    adaptor.append(buffer, withPresentationTime: CMTime(seconds: seconds, preferredTimescale: 1))
                    
                    seconds += frame.duration
                }
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
    
    public static func animation(from frames: [Frame], size: CGSize, outputURL: URL, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
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
                
                CGImageDestinationAddImage(destination, frame.image, frameProperties as CFDictionary)
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

private extension Animator {
    
   static func pixelBuffer(fromImage image: CGImage, size: CGSize, attributes: [String : Any]) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let data = CVPixelBufferGetBaseAddress(buffer) else { return nil }
    
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
    
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    
        guard let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
}
