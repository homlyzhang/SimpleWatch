//
//  StatisticsToolTest.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 6/3/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import XCTest
import CoreLocation

class StatisticsToolTest: XCTestCase {

    let staTool = StatisticsTool()
    let msFormatter = DateFormatter()
    var locations = [CLLocation]()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        msFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        locations = [CLLocation]()
        let cvtTool = ConvertTool()
        locations.append(cvtTool.dictToLocation(["latitude": 0.01, "longitude": 0.03, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.456")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.02, "longitude": 0.03, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.532")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.04, "longitude": 0.03, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.865")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.08, "longitude": 0.03, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.426")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.08, "longitude": 0.05, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.756")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.08, "longitude": 0.09, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.156")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.09, "longitude": 0.11, "altitude": 0.07], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.476")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.09, "longitude": 0.11, "altitude": 0.09], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.496")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.09, "longitude": 0.11, "altitude": 0.09], timestamp: msFormatter.date(from: "2017-03-06 23:26:19.480")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.09, "longitude": 0.11, "altitude": 0.09], timestamp: msFormatter.date(from: "2017-03-06 23:26:21.304")! as NSDate))
        locations.append(cvtTool.dictToLocation(["latitude": 0.09, "longitude": 0.11, "altitude": 0.10], timestamp: msFormatter.date(from: "2017-03-06 23:26:21.456")! as NSDate))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
/*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
*/
    func testGetSecondLocations() {
        let secLocations = staTool.getSecondLocations(locations)
        XCTAssert(secLocations.count == 5)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[0].timestamp), "2017-03-06 23:26:13.618") != 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[1].timestamp), "2017-03-06 23:26:14.591") != 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[3].timestamp), "2017-03-06 23:26:19.408") != 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[4].timestamp), "2017-03-06 23:26:21.380") != 0)
    }
/*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
