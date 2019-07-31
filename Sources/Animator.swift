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

public struct Animator {
    
    struct Frame {
        var image: CGImage
        var duration: Double
    }
    
    static func movie(from frames: [Frame], size: CGSize, outputURL: URL, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        var assetWriter: AVAssetWriter
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        } catch {
            completion(error)
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
                    DispatchQueue.main.async { completion(error) }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }
    }
    
    static func animation(from frames: [Frame], size: CGSize, outputURL: URL, queue: DispatchQueue = DispatchQueue(label: "Animator"), completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
}
    
extension Animator {
    
    static func frames(from images: [CGImage], duration: Double = 1.0) -> [Frame] {
        return images.map { (image) -> Frame in
            return Frame(image: image, duration: duration)
        }
    }
    
}

extension Animator {
    
    private static func pixelBuffer(fromImage image: CGImage, size: CGSize, attributes: [String : Any]) -> CVPixelBuffer? {
        var pxbuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pxbuffer)
        guard let buffer = pxbuffer, status == kCVReturnSuccess else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let pxdata = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
}
