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

    let msFormatter = DateFormatter()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        msFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
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
        var locations = [CLLocation]()
        locations.append(ConvertTool.dictToLocation(["latitude": 0.001, "longitude": 0.003, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.456")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.002, "longitude": 0.003, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.532")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.004, "longitude": 0.003, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.865")! as NSDate))

        locations.append(ConvertTool.dictToLocation(["latitude": 0.008, "longitude": 0.003, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.426")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.008, "longitude": 0.005, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.756")! as NSDate))
        
        locations.append(ConvertTool.dictToLocation(["latitude": 0.008, "longitude": 0.009, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.156")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.009, "longitude": 0.011, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.476")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.009, "longitude": 0.011, "altitude": 19.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.496")! as NSDate))
        
        locations.append(ConvertTool.dictToLocation(["latitude": 0.009, "longitude": 0.011, "altitude": 19.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:19.480")! as NSDate))
        
        locations.append(ConvertTool.dictToLocation(["latitude": 0.009, "longitude": 0.011, "altitude": 19.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:21.304")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.009, "longitude": 0.011, "altitude": 31.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:21.456")! as NSDate))

        let secLocations = StatisticsTool.getSecondLocations(locations)
        XCTAssert(secLocations.count == 5)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[0].timestamp), "2017-03-06 23:26:13.618") == 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[1].timestamp), "2017-03-06 23:26:14.591") == 0)
        XCTAssert(secLocations[1].coordinate.latitude == 0.008)
        XCTAssert(secLocations[1].coordinate.longitude == 0.004)
        XCTAssert(secLocations[1].altitude == 7.00)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[3].timestamp), "2017-03-06 23:26:19.480") == 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[4].timestamp), "2017-03-06 23:26:21.380") == 0)
    }

    func testDistance() {
        var locations = [CLLocation]()
        locations.append(ConvertTool.dictToLocation(["latitude": 0.001, "longitude": 0.003, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.456")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.002, "longitude": 0.004, "altitude": 70.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.456")! as NSDate))

        let d = StatisticsTool.distance(locations)
        print("\n\(d)\n")
        XCTAssert(abs(d - 163.8) < 10)
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
