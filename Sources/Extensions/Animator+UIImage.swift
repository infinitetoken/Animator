//
//  Animator+UIImage.swift
//  Animator
//
//  Created by Aaron Wright on 7/31/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension Animator.Frame {
    
    init?(image: UIImage, duration: Double, position: Int = 0, background: UIColor = UIColor.black) {
        guard let cgImage = image.cgImage else { return nil }
        
        self.image = cgImage
        self.duration = duration
        self.position = position
        self.background = background.cgColor
    }
    
}

#endif
