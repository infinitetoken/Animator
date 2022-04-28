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
import UniformTypeIdentifiers

#if os(iOS) || os(tvOS)
import MobileCoreServices
#endif

public struct Animator {
    
    // MARK: - Enums
    
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
    
    public enum MovieType: String {
        case mov = "mov"
        case mp4 = "mp4"
        
        var fileExtension: String { self.rawValue }
        
        var fileType: AVFileType {
            switch self {
            case .mov:
                return AVFileType.mov
            case .mp4:
                return AVFileType.mp4
            }
        }
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
    
    public static func animation(from frames: [Frame], size: CGSize? = nil) async -> Data? {
        let width = frames.max { (a, b) -> Bool in
            return a.image.width < b.image.width
        }?.image.width ?? 0
        let height = frames.max { (a, b) -> Bool in
            return a.image.height < b.image.height
        }?.image.height ?? 0
        let size = size ?? CGSize(width: width, height: height)
        
        guard size.width > 0, size.height > 0 else { return nil }
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String:[
            kCGImagePropertyGIFLoopCount as String: NSNumber(value: Int32(0) as Int32)],
            kCGImagePropertyGIFHasGlobalColorMap as String: NSValue(nonretainedObject: true)
        ] as [String : Any]
        
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, frames.count, nil) else { return nil }
        
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
        
        CGImageDestinationFinalize(destination)
        
        return data as Data
    }
    
    public static func movie(from frames: [Frame], size: CGSize? = nil, movieType: MovieType = .mov) async -> Data? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).\(movieType.fileExtension)")
        
        guard let assetWriter: AVAssetWriter = try? AVAssetWriter(url: url, fileType: movieType.fileType) else { return nil }
        
        let width = frames.max { (a, b) -> Bool in
            return a.image.width < b.image.width
        }?.image.width ?? 0
        let height = frames.max { (a, b) -> Bool in
            return a.image.height < b.image.height
        }?.image.height ?? 0
        let size = size ?? CGSize(width: width, height: height)
        
        guard size.width > 0, size.height > 0 else { return nil }
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: settings)
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: attributes)
        
        assetWriter.add(assetWriterInput)
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        var frameIndex: Int = 0
        var frameTime: Double = 0.0
        
        while assetWriterInput.isReadyForMoreMediaData && frameIndex < frames.count {
            let frame = frames[frameIndex]
            
            if let image = frame.image.centered(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), background: frame.background), let buffer = image.pixelBuffer(size: size) {
                adaptor.append(buffer, withPresentationTime: CMTime(seconds: frameTime, preferredTimescale: 1000))

                frameTime += frame.duration
            }
            
            frameIndex += 1
        }
        
        assetWriterInput.markAsFinished()
        
        await assetWriter.finishWriting()
        
        return try? Data(contentsOf: url)
    }
    
    public static func frames(from images: [CGImage], duration: Double, background: CGColor) -> [Frame] {
        return images.map { (image) -> Frame in
            return Frame(image: image, duration: duration, background: background)
        }
    }
    
}
