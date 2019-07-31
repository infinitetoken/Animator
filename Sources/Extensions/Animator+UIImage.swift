//
//  File.swift
//  
//
//  Created by Aaron Wright on 7/31/19.
//

#if os(iOS) || os(tvOS)
import UIKit

extension Animator {
    
    static func frames(from images: [UIImage], duration: Double = 1.0) -> [Frame] {
        return images.map({ (image) -> CGImage? in
            image.cgImage
        }).compactMap({ $0 }).map { (image) -> Frame in
            return Frame(image: image, duration: duration)
        }
    }
    
}
#endif
