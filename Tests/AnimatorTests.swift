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
    
    var webURLs: [URL] = [
        URL(string: "https://via.placeholder.com/100x100.jpg?text=1")!,
        URL(string: "https://via.placeholder.com/200x100.gif?text=2")!,
        URL(string: "https://via.placeholder.com/400x200.png?text=3")!
    ]
    
    var urls: [URL] = []
    
    // MARK: - Properties

    #if os(macOS)
    var images: [CGImage] {
        self.urls.map { (url) -> Data? in
            try? Data(contentsOf: url)
        }.compactMap({ $0 }).map { (data) -> NSImage? in
            NSImage(data: data)
        }.compactMap({ $0 }).map { (image) -> CGImage? in
            var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

            return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        }.compactMap({ $0 })
    }
    var backgroundColor: CGColor {
        return CGColor.black
    }
    #endif

    #if os(iOS) || os(tvOS)
    var images: [CGImage] {
        self.urls.map { (url) -> Data? in
            try? Data(contentsOf: url)
        }.compactMap({ $0 }).map { (data) -> UIImage? in
            UIImage(data: data)
        }.compactMap({ $0 }).map { (image) -> CGImage? in
            return image.cgImage
        }.compactMap({ $0 })
    }
    var backgroundColor: CGColor {
        return UIColor.black.cgColor
    }
    #endif
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        
        self.generateImages()
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.removeImages()
    }
    
    // MARK: - Tests
    
    func testCanCreateAnimation() async {
        let data1 = await Animator.animation(from: Animator.frames(from: self.images, duration: 1), type: .gif)
        
        XCTAssertNotNil(data1)
        
        let data2 = await Animator.animation(from: Animator.frames(from: self.images, duration: 1), type: .apng)
        
        XCTAssertNotNil(data2)
    }
    
    // MARK: - Helpers
    
    private func generateImages() {
        let expectation = XCTestExpectation(description: "Generate Images")
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        var count = 0
        
        webURLs.enumerated().forEach { (url) in
            URLSession.shared.dataTask(with: url.element) { (data, response, error) in
                let uuid = UUID()
                let ext = url.element.pathExtension
                
                let fileURL = cacheURL.appendingPathComponent(uuid.uuidString).appendingPathExtension(ext)
                
                try? data?.write(to: fileURL)
                
                self.urls.append(fileURL)
                
                count += 1
                
                if count == self.webURLs.count {
                    expectation.fulfill()
                }
            }.resume()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    private func removeImages() {
        let fileManager = FileManager.default
        
        for url in self.urls {
            if fileManager.fileExists(atPath: url.path) {
                try! fileManager.removeItem(at: url)
            }
        }
    }
    
}
