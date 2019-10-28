//
//  File.swift
//  
//
//  Created by Aaron Wright on 10/28/19.
//

import Foundation
import CoreGraphics

extension CGRect {
    
    func centered(in containingRect: CGRect) -> CGRect {
        let originX = containingRect.origin.x + ((containingRect.size.width - self.size.width) * 0.5)
        let originY = containingRect.origin.y + ((containingRect.size.height - self.size.height) * 0.5)
        
        return CGRect(x: originX, y: originY, width: self.size.width, height: self.size.height).integral
    }
    
}
