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
        locations.append(ConvertTool.dictToLocation(["longitude":114.2048726369379,"latitude":22.41976549332886,"altitude":21.99795913696289], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.456")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["longitude":114.2048726369379,"latitude":22.41976549332886,"altitude":21.99795913696289], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.532")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["longitude":114.2048726369379,"latitude":22.41976549332886,"altitude":21.99795913696289], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.865")! as NSDate))

        locations.append(ConvertTool.dictToLocation(["longitude":114.2048726369379,"latitude":22.41976549332886,"altitude":21.99795913696289], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.426")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["longitude":114.2048997513458,"latitude":22.4197474375494,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.756")! as NSDate))
        
        locations.append(ConvertTool.dictToLocation(["longitude":114.2048997513458,"latitude":22.4197474375494,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.156")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["longitude":114.2049539801616,"latitude":22.4197474375494,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.476")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["longitude":114.2049539801616,"latitude":22.41971132599048,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:18.496")! as NSDate))
        
        locations.append(ConvertTool.dictToLocation(["longitude":114.2050353233853,"latitude":22.41971132599048,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:19.480")! as NSDate))
        
        locations.append(ConvertTool.dictToLocation(["longitude":114.2050353233853,"latitude":22.4196571586521,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:21.304")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["longitude":114.2051437810169,"latitude":22.4196571586521,"altitude":21.99816703796387], timestamp: msFormatter.date(from: "2017-03-06 23:26:21.456")! as NSDate))

        let secLocations = StatisticsTool.getSecondLocations(locations)
        XCTAssert(secLocations.count == 5)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[0].timestamp), "2017-03-06 23:26:13.618") == 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[1].timestamp), "2017-03-06 23:26:14.591") == 0)
        print("\(secLocations[1].coordinate.latitude)")
        XCTAssert(secLocations[1].coordinate.latitude == 22.41975646543913)
        print("\(secLocations[1].coordinate.longitude)")
        XCTAssert(secLocations[1].coordinate.longitude == 114.20488619414186)
        XCTAssert(secLocations[1].altitude == 21.99806308746338)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[3].timestamp), "2017-03-06 23:26:19.480") == 0)
        XCTAssert(strcmp(msFormatter.string(from: secLocations[4].timestamp), "2017-03-06 23:26:21.380") == 0)
    }

    func testDistance() {
        var locations = [CLLocation]()
        locations.append(ConvertTool.dictToLocation(["latitude": 0.001, "longitude": 0.003, "altitude": 7.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:13.456")! as NSDate))
        locations.append(ConvertTool.dictToLocation(["latitude": 0.002, "longitude": 0.004, "altitude": 70.00], timestamp: msFormatter.date(from: "2017-03-06 23:26:14.456")! as NSDate))

        let d = StatisticsTool.distance(locations)
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
