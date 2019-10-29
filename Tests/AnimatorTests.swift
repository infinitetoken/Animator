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
    
    struct TestImage {
        var size: CGSize
        var ext: String
        var position: Int
    }
    
    struct TestURL {
        var url: URL
        var position: Int
    }
    
    var testImages: [TestImage] {
        return [
            TestImage(size: CGSize(width: 100, height: 100), ext: "png", position: 0),
            TestImage(size: CGSize(width: 200, height: 100), ext: "png", position: 1),
            TestImage(size: CGSize(width: 400, height: 200), ext: "png", position: 2)
        ]
    }
    var urls: [TestURL] = []
    
    // MARK: - Properties

    #if os(macOS)
    var images: [CGImage] {
        self.urls.map { (testURL) -> Data? in
            try? Data(contentsOf: testURL.url)
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
        
        for index in 1...self.testImages.count {
            let testImage = self.testImages[index - 1]
            let url = URL(string: "https://via.placeholder.com/\(Int(testImage.size.width))x\(Int(testImage.size.height)).\(testImage.ext)?text=\(index)")!
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                let uuid = UUID()
                let fileURL = cacheURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("png")
                
                try? data?.write(to: fileURL)
                
                self.urls.append(TestURL(url: fileURL, position: testImage.position))
                
                if index == self.testImages.count {
                    expectation.fulfill()
                }
            }.resume()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    private func removeImages() {
        let fileManager = FileManager.default
        
        for testURL in self.urls {
            if fileManager.fileExists(atPath: testURL.url.path) {
                try! fileManager.removeItem(at: testURL.url)
            }
        }
    }
    
}
