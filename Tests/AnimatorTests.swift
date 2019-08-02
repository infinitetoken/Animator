//
//  AnimatorTests.swift
//  Animator
//
//  Created by Aaron Wright on 7/16/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

import XCTest
@testable import Animator

final class AnimatorTests: XCTestCase {
    
    var imageStrings: [String] {
        return [
            "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkBAMAAACCzIhnAAAAG1BMVEXMzMyWlpaxsbHFxcWcnJy+vr6jo6O3t7eqqqrWjUlXAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAARUlEQVRYhe3PMRGAMAAEwZAhAjJRFAk0TGwggQ7ZaPiCit3+iisFAPi9OuJkz5MjTtpMk3P2NLl6nKznzvc3iUQCAHzuBVKmBP9aru02AAAAAElFTkSuQmCC",
            "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkBAMAAACCzIhnAAAAG1BMVEXMzMyWlpa3t7ejo6OcnJyxsbHFxcW+vr6qqqr4Es4jAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAnUlEQVRYhe3SvQ3CMBCG4csfpOSCA5QgFkBCQrQuEC1sQMQCsAHZHDsbvKLke4rrXp1t2UxERET+3T5eHqyo3P3KkjGcY0DFzD/W+JYkTd4wHkhS9Wm8FySpuzSGFUmKdR4omb+MHmzCrp/BR56WLGnxdHqu0jd0yR3fpPUTXbLraWHxRosSP7C1HU7qcEzQCxSeoZ888ERERER+8AWQCwzw4RcUHwAAAABJRU5ErkJggg==",
            "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkBAMAAACCzIhnAAAAG1BMVEXMzMyWlpa3t7eqqqqcnJyjo6PFxcWxsbG+vr6NAD6nAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAApklEQVRYhe3TMRKCMBSE4acgULqaMJRyA5lBay3sZcYDhBuYRlu4ucEbrK371fzzILyYiYiIyL9b9/5MJh2AA1WU8CfUVJK7YPOeSuYmTfJU0m7NKlBJvKfEUcki414sKeKOLHLgSCYrYOKThkysGujPtw33X75jEJjH31M6ZS65PpeEKazjFybW9MKMPljLLUyGW48LlRQDkC4mpXy4F1eIiIjI7z5jvA50DBoRsQAAAABJRU5ErkJggg=="
        ]
    }
    
    #if os(macOS)
    var images: [CGImage] {
        self.imageStrings.map { (base64String) -> Data? in
            Data(base64Encoded: base64String)
        }.compactMap({ $0 }).map { (data) -> NSImage? in
            NSImage(data: data)
        }.compactMap({ $0 }).map { (image) -> CGImage? in
            var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            
            return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        }.compactMap({ $0 })
    }
    #endif
    
    #if os(iOS) || os(tvOS)
    var images: [CGImage] {
        self.imageStrings.map { (base64String) -> Data? in
            Data(base64Encoded: base64String)
        }.compactMap({ $0 }).map { (data) -> UIImage? in
            UIImage(data: data)
        }.compactMap({ $0 }).map { (image) -> CGImage? in
            return image.cgImage
        }.compactMap({ $0 })
    }
    #endif
    
    func testCanCreateMovie() {
        let uuid = UUID()
        let fileManager = FileManager.default
        let url = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("downloads/\(uuid.uuidString).mov")
        
        Swift.print(url)
        
        let expectation = XCTestExpectation(description: "Create Movie")
        
        Animator.movie(from: Animator.frames(from: self.images), size: CGSize(width: 100, height: 100), outputURL: url) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertTrue(fileManager.fileExists(atPath: url.path))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testCanCreateAnimation() {
        let uuid = UUID()
        let fileManager = FileManager.default
        let url = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("downloads/\(uuid.uuidString).gif")
        
        Swift.print(url)
        
        let expectation = XCTestExpectation(description: "Create Animation")
        
        Animator.animation(from: Animator.frames(from: self.images), size: CGSize(width: 100, height: 100), outputURL: url) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertTrue(fileManager.fileExists(atPath: url.path))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
}
