//
//  HearthstoneTests.swift
//  VideoOsx
//
//  Copyright (c) 2014 Charles Gutjahr. See README.md for license details.
//

import Foundation
import XCTest
import VideoOsx

class HearthstoneTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPid() {
        let hsr = HearthstoneRecorder()
        let pid = hsr.findPid()
        XCTAssertNotEqual(0, pid, "PID should be non-zero")
        
    }
    
    func testWindowBounds() {
        let hsr = HearthstoneRecorder()
        let pid = hsr.findPid()
        let bounds = hsr.getHSWindowBounds()
        XCTAssertNotEqual("Found Nothing", bounds, "Should find Hearthstone")
        
    }
    
    func testRunVideo() {
        let hsr = HearthstoneRecorder()

        let pid = hsr.findPid()
        let bounds = hsr.getHSWindowBounds()
        
        hsr.startRecording()
        
        sleep(5)
        
        let result = hsr.stopRecording()
        println("Result = \"\(result)\"")
        
        sleep(2)
        
    }
    
}