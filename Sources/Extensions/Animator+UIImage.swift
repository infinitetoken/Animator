//
//  Animator+UIImage.swift
//  Animator
//
//  Created by Aaron Wright on 7/31/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension Animator {
    
    static func frames(from images: [UIImage], duration: Double = 1.0, background: UIColor = UIColor.black) -> [Frame] {
        return images.map({ (image) -> CGImage? in
            image.cgImage
        }).compactMap({ $0 }).map { (image) -> Frame in
            return Frame(image: image, duration: duration, background: background.cgColor)
        }
    }
    
}

public extension Animator.Frame {
    
    init?(image: UIImage, duration: Double, background: UIColor = UIColor.black) {
        guard let cgImage = image.cgImage else { return nil }
        
        self.image = cgImage
        self.duration = duration
        self.background = background.cgColor
    }
    
}

#endif
