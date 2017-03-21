//
//  FileToolTest.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 20/3/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import XCTest

class FileToolTest: XCTestCase {

    let fileName = "unit_test.txt"
    let ls = FileTool.lineSeperator

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let sArray = ["aaaa", "bbba", "aacc", "bbaa", "bbac", "aavv"]
        let s = sArray.joined(separator: FileTool.lineSeperator)
        let data = s.data(using: .utf8)!
        FileTool.delete(fileName)
        FileTool.append(data: data, to: fileName)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRead() {
        let getString = FileTool.read(fileName)
        XCTAssert(getString.compare("aaaa\(ls)bbba\(ls)aacc\(ls)bbaa\(ls)bbac\(ls)aavv") == .orderedSame)
    }

    func testReadTextAndEnd() {
        var getString: String
        var end: UInt64
        (getString, end) = FileTool.readTextAndEnd(fileName)
        XCTAssert(getString == "aaaa\(ls)bbba\(ls)aacc\(ls)bbaa\(ls)bbac\(ls)aavv")
        XCTAssert(end == 29)
    }

    func testReadLastRows() {
        var getString: String
        getString = FileTool.read(from: fileName, lastRows: 3)
        XCTAssert(getString == "bbaa\(ls)bbac\(ls)aavv")
        getString = FileTool.read(from: fileName, lastRows: 7)
        XCTAssert(getString == "aaaa\(ls)bbba\(ls)aacc\(ls)bbaa\(ls)bbac\(ls)aavv")
    }

    func testReadLastRowsAndEnd() {
        var getString: String
        var end: UInt64
        (getString, end) = FileTool.readTextAndEnd(from: fileName, lastRows: 3)
        XCTAssert(getString == "bbaa\(ls)bbac\(ls)aavv")
        XCTAssert(end == 29)
        (getString, end) = FileTool.readTextAndEnd(from: fileName, lastRows: 7)
        XCTAssert(getString == "aaaa\(ls)bbba\(ls)aacc\(ls)bbaa\(ls)bbac\(ls)aavv")
        XCTAssert(end == 29)
    }

    func testReadFromOffset() {
        let getString = FileTool.read(from: fileName, beginWith: 10)
        XCTAssert(getString == "aacc\(ls)bbaa\(ls)bbac\(ls)aavv")
    }

    func testReadLineFromOffset() {
        let getString = FileTool.readLine(from: fileName, beginWith: 10)
        XCTAssert(getString == "aacc")
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
