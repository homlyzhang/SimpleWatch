//
//  WatchData.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 28/11/2016.
//  Copyright © 2016 Homly ZHANG. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

class WatchData {
    var userAccelerations = [NSDate : CMAcceleration]()
    var accelerations = [NSDate : CMAcceleration]()
    var rotationRates = [NSDate : CMRotationRate]()
    var locations = [NSDate : CLLocation]()

    static private var locationCache = LocationCacheClass()
    static private var accelerationCache = AccelerationCacheClass()
    static private let fileSuffix = [
        "userAcceleration": "_userAcceleration.txt",
        "acceleration": "_acceleration.txt",
        "rotationRate": "_rotationRate.txt",
        "location": "_location.txt"
    ]

    public init() {}
    public init(_ data: [String : Any]) {
        if data["userAcceleration"] != nil {
            self.userAccelerations = ConvertTool.dictArrayToAccelerationArray(data["userAcceleration"] as! [NSDate: Dictionary<String, Double>])
        }
        if data["acceleration"] != nil {
            self.accelerations = ConvertTool.dictArrayToAccelerationArray(data["acceleration"] as! [NSDate: Dictionary<String, Double>])
        }
        if data["rotationRate"] != nil {
            self.rotationRates = ConvertTool.dictArrayToRotationRateArray(data["rotationRate"] as! [NSDate: Dictionary<String, Double>])
        }
        if data["location"] != nil {
            self.locations = ConvertTool.dictArrayToLocationArray(data["location"] as! [NSDate: Dictionary<String, Double>])
        }
    }

    private func appendToFile(_ dictArray: [NSDate : Dictionary<String, Double>], fileSuffix: String) {
        var data = Data()
        let returnData = FileTool.lineSeperator.data(using: .utf8)!
        var dateStr = "", timeStr = ""
        let formatter = DateTool.getMillSecFormat()

        let dateDictArray = dictArray as [Date: Dictionary<String, Double>]
        for time in dateDictArray.keys.sorted() {
            let dict = dateDictArray[time]!
            timeStr = formatter.string(from: time)
            let dateEndIndex = timeStr.index(timeStr.startIndex, offsetBy: 8)
            if dateStr == "" {
                dateStr = timeStr.substring(to: dateEndIndex)
            }
            let tempDictDict = [timeStr.substring(from: dateEndIndex): dict]
            do {
                data.append(try JSONSerialization.data(withJSONObject: tempDictDict, options: []))
                data.append(returnData)
            }
            catch {
                NSLog(error.localizedDescription)
            }
        }
        if dateStr != "" {
            FileTool.append(data: data, to: dateStr + fileSuffix)
        }
    }

    func appendToFile() {
        let message = ConvertTool.makeSendMessage(userAccelerations: self.userAccelerations, accelerations: self.accelerations, rotationRates: self.rotationRates, locations: self.locations)
        for property in ["userAcceleration", "acceleration", "rotationRate", "location"] {
            appendToFile(message[property] as! [NSDate : Dictionary<String, Double>], fileSuffix: WatchData.fileSuffix[property]!)
        }
    }

    static func clearLocations() {
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: Date())
        FileTool.delete("\(dateStr)\(fileSuffix["location"]!)")

        locationCache = LocationCacheClass()
    }

    static func getLatestLocations(date: Date, num: Int) -> [CLLocation] {
//        let time_start = Date()
        var result: [CLLocation]
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: date)
        let lastRows: String
        let fileName = "\(dateStr)\(fileSuffix["location"]!)"

        if num >= 0 {
            lastRows = FileTool.read(from: fileName, lastRows: num)
            result = ConvertTool.stringToLocations(fileText: lastRows, dateStr: dateStr)
        } else {
            var end: UInt64
            let dateDate = dateFormatter.date(from: dateStr)!
            if locationCache.date.timeIntervalSince1970 == 0 || locationCache.date.timeIntervalSince1970 != dateDate.timeIntervalSince1970 {
                (lastRows, end) = FileTool.readTextAndEnd(fileName)
                result = ConvertTool.stringToLocations(fileText: lastRows, dateStr: dateStr)
                locationCache = LocationCacheClass(date: dateDate, locations: result, end: end)
            } else {
                result = locationCache.locations
                (lastRows, end) = FileTool.readTextAndEnd(from: fileName, beginWith: locationCache.end)
                let newLocations = ConvertTool.stringToLocations(fileText: lastRows, dateStr: dateStr)
//                if result.last != nil && newLocations.first != nil {
//                    let timeFormatter = DateFormatter()
//                    timeFormatter.dateFormat = "HHmmssSSS"
//                    print("\(timeFormatter.string(from: result.last!.timestamp))---\(newLocations.count)---\(timeFormatter.string(from: newLocations.first!.timestamp))")
//                }
                result.append(contentsOf: newLocations)
                locationCache = LocationCacheClass(date: dateDate, locations: result, end: end)
            }
        }
//        print("getLatestLocations: \(((Date().timeIntervalSince1970 - time_start.timeIntervalSince1970) * 1000).rounded() / 1000)s, \(result.count) locations")
        return result
    }

    static func clearAccelerations() {
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: Date())
        FileTool.delete("\(dateStr)\(fileSuffix["acceleration"]!)")

        accelerationCache = AccelerationCacheClass()
    }

    static func getLatestAccelerations(date: Date, num: Int) -> ([CMAcceleration], Date) {
        let time_start = Date()
        var result: [CMAcceleration]
        var lastDate: Date
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: date)
        let lastRows: String
        let fileName = "\(dateStr)\(fileSuffix["acceleration"]!)"
        
        if num >= 0 {
            lastRows = FileTool.read(from: fileName, lastRows: num)
            (result, lastDate) = ConvertTool.stringToAccelerations(fileText: lastRows, dateStr: dateStr)
        } else {
            var end: UInt64
            let dateDate = dateFormatter.date(from: dateStr)!
            if accelerationCache.date.timeIntervalSince1970 == 0 || accelerationCache.date.timeIntervalSince1970 != dateDate.timeIntervalSince1970 {
                (lastRows, end) = FileTool.readTextAndEnd(fileName)
                (result, lastDate) = ConvertTool.stringToAccelerations(fileText: lastRows, dateStr: dateStr)
                accelerationCache = AccelerationCacheClass(date: dateDate, accelerations: result, end: end)
            } else {
                result = accelerationCache.accelerations
                (lastRows, end) = FileTool.readTextAndEnd(from: fileName, beginWith: accelerationCache.end)
                let newAccelerations: [CMAcceleration]
                (newAccelerations, lastDate) = ConvertTool.stringToAccelerations(fileText: lastRows, dateStr: dateStr)
                result.append(contentsOf: newAccelerations)
                accelerationCache = AccelerationCacheClass(date: dateDate, accelerations: result, end: end)
            }
        }
        print("getLatestAccelerations: \(((Date().timeIntervalSince1970 - time_start.timeIntervalSince1970) * 1000).rounded() / 1000)s, \(result.count) accelerations")
        return (result, lastDate)
    }
}

private struct LocationCacheClass {
    var date = Date.init(timeIntervalSince1970: 0)
    var locations = [CLLocation]()
    var end = UInt64(0)

    init() {}
    init(date: Date, locations: [CLLocation], end: UInt64) {
        self.date = date
        self.locations = locations
        self.end = end
    }
}

private struct AccelerationCacheClass {
    var date = Date.init(timeIntervalSince1970: 0)
    var accelerations = [CMAcceleration]()
    var end = UInt64(0)
    
    init() {}
    init(date: Date, accelerations: [CMAcceleration], end: UInt64) {
        self.date = date
        self.accelerations = accelerations
        self.end = end
    }
}
