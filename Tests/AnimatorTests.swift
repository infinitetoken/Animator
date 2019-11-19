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
        URL(string: "https://via.placeholder.com/100x100.png?text=1")!,
        URL(string: "https://via.placeholder.com/100x100.png?text=2")!,
        URL(string: "https://via.placeholder.com/100x100.png?text=3")!,
        URL(string: "https://via.placeholder.com/100x100.png?text=4")!
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
        self.urls.map { (testURL) -> Data? in
            try? Data(contentsOf: testURL.url)
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
    
    func testCanCreateMovie() {
        let uuid = UUID()
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appendingPathComponent("\(uuid.uuidString).mov")

        let expectation = XCTestExpectation(description: "Create Movie")

        Animator.movie(from: Animator.frames(from: self.images, duration: 1, background: self.backgroundColor), outputURL: url) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertTrue(fileManager.fileExists(atPath: url.path))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCanCreateAnimation() {
        let uuid = UUID()
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appendingPathComponent("\(uuid.uuidString).gif")

        let expectation = XCTestExpectation(description: "Create Animation")

        Animator.animation(from: Animator.frames(from: self.images, duration: 1, background: self.backgroundColor), outputURL: url) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            XCTAssertTrue(fileManager.fileExists(atPath: url.path))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Helpers
    
    private func generateImages() {
        let expectation = XCTestExpectation(description: "Generate Images")
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        webURLs.enumerated().forEach { (url) in
            URLSession.shared.dataTask(with: url.element) { (data, response, error) in
                let uuid = UUID()
                let ext = url.element.pathExtension
                
                let fileURL = cacheURL.appendingPathComponent(uuid.uuidString).appendingPathExtension(ext)
                
                try? data?.write(to: fileURL)
                
                self.urls.append(fileURL)
                
                if url.offset == self.webURLs.count - 1 {
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
