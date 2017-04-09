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

    static private var velocityCache = [Velocity]()
    static private let velocityMaxSize = 100
    static private var userAccelerationCache = AccelerationCacheClass()
    static private var accelerationCache = AccelerationCacheClass()
    static private var locationCache = LocationCacheClass()
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

    static func clearVelocity() {
        velocityCache = [Velocity]()
        velocityCache.append(Velocity(Date()))
    }

    static func getLatestVelocity(num: Int) -> [Velocity] {
        let time_start = Date()
        var result = [Velocity]()
        let resultNum = max(num, 1)
        let userAccelerations: [CMAcceleration]
        let timeArray: [Date]
        let now = Date()
        let dateStr = DateTool.getDateFormat().string(from: now)
        let fileName = "\(dateStr)\(fileSuffix["userAcceleration"]!)"
        let oldVelocityCount = velocityCache.count

        userAccelerationCache = refreshAccelerationCache(date: now, fileName: fileName, accelerationCache: userAccelerationCache)
        userAccelerations = userAccelerationCache.accelerations
        timeArray = userAccelerationCache.timestamps

        for i in 0...userAccelerations.count - 1 {
            let acc = userAccelerations[i]
            let time = timeArray[i]
            if velocityCache.count == 0 || time.timeIntervalSince1970 > velocityCache.last!.timestamp.timeIntervalSince1970 {
                updateVelocityCache(userAcceleration: acc, time: time)
            }
        }

        for i in max(velocityCache.count - resultNum, 0)...velocityCache.count - 1 {
            result.append(velocityCache[i])
        }

        print("getLatestVelocity: \(((Date().timeIntervalSince1970 - time_start.timeIntervalSince1970) * 1000).rounded() / 1000)s, \(velocityCache.count - oldVelocityCount) velocity")
        return result
    }

    static private func updateVelocityCache(userAcceleration: CMAcceleration, time: Date) {
        if velocityCache.count == 0 {
            velocityCache.append(Velocity(acceleration: userAcceleration, time: time))
        } else {
            velocityCache.append(velocityCache.last!.toTime(acceleration: userAcceleration, time: time))
        }
    }

    static func clearAccelerations() {
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: Date())
        FileTool.delete("\(dateStr)\(fileSuffix["acceleration"]!)")
        
        accelerationCache = AccelerationCacheClass()
    }

    static func getLatestAccelerations(date: Date, num: Int) -> ([CMAcceleration], Date) {
//        let time_start = Date()
        var result: [CMAcceleration]
        var lastDate = Date.init(timeIntervalSince1970: 0)
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: date)
        let lastRows: String
        let fileName = "\(dateStr)\(fileSuffix["acceleration"]!)"
        
        if num >= 0 {
            lastRows = FileTool.read(from: fileName, lastRows: num)
            (result, lastDate) = ConvertTool.stringToAccelerations(fileText: lastRows, dateStr: dateStr)
        } else {
            accelerationCache = refreshAccelerationCache(date: date, fileName: fileName, accelerationCache: accelerationCache)
            result = accelerationCache.accelerations
            if accelerationCache.timestamps.count > 0 {
                lastDate = accelerationCache.timestamps.last!
            }
            
        }
//        print("getLatestAccelerations: \(((Date().timeIntervalSince1970 - time_start.timeIntervalSince1970) * 1000).rounded() / 1000)s, \(result.count) accelerations")
        return (result, lastDate)
    }

    static private func refreshAccelerationCache(date: Date, fileName: String, accelerationCache: AccelerationCacheClass) -> AccelerationCacheClass {
        var end: UInt64
        var accelerations: [CMAcceleration]
        var timestamps: [Date]
        let dateFormatter = DateTool.getDateFormat()
        let dateStr = dateFormatter.string(from: date)
        let dateDate = dateFormatter.date(from: dateStr)!
        let lastRows: String

        if accelerationCache.date.timeIntervalSince1970 == 0 || accelerationCache.date.timeIntervalSince1970 != dateDate.timeIntervalSince1970 {
            (lastRows, end) = FileTool.readTextAndEnd(fileName)
            (accelerations, timestamps, _) = ConvertTool.stringToAccelerationsAndTime(fileText: lastRows, dateStr: dateStr)
        } else {
            accelerations = accelerationCache.accelerations
            timestamps = accelerationCache.timestamps
            (lastRows, end) = FileTool.readTextAndEnd(from: fileName, beginWith: accelerationCache.end)
            let newAccelerations: [CMAcceleration]
            let newTimestamps: [Date]
            (newAccelerations, newTimestamps, _) = ConvertTool.stringToAccelerationsAndTime(fileText: lastRows, dateStr: dateStr)
            accelerations.append(contentsOf: newAccelerations)
            timestamps.append(contentsOf: newTimestamps)
        }

        return AccelerationCacheClass(date: dateDate, accelerations: accelerations, timestamps: timestamps, end: end)
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
    var timestamps = [Date]()
    var end = UInt64(0)
    
    init() {}
    init(date: Date, accelerations: [CMAcceleration], timestamps: [Date], end: UInt64) {
        self.date = date
        self.accelerations = accelerations
        self.timestamps = timestamps
        self.end = end
    }
    init(date: Date, accelerations: [CMAcceleration], end: UInt64) {
        self.init(date: date, accelerations: accelerations, timestamps: [Date](), end: end)
    }
}

public struct Velocity {
    var velocityX: Double
    var velocityY: Double
    var velocityZ: Double
    var acceleration: CMAcceleration
    var timestamp: Date

    init(x: Double, y: Double, z: Double, acceleration: CMAcceleration, time: Date) {
        self.velocityX = x
        self.velocityY = y
        self.velocityZ = z
        self.acceleration = acceleration
        self.timestamp = time
    }
    init(acceleration: CMAcceleration, time: Date) {
        self.init(x: 0.0, y: 0.0, z: 0.0, acceleration: acceleration, time: time)
    }
    init(_ time: Date) {
        self.init(acceleration: CMAcceleration(), time: time)
    }

    func toTime(acceleration: CMAcceleration, time: Date) -> Velocity {
        let seconds = time.timeIntervalSince1970 - timestamp.timeIntervalSince1970
        return Velocity(x: self.velocityX + self.acceleration.x * seconds, y: self.velocityY + self.acceleration.y * seconds, z: self.velocityZ + self.acceleration.z * seconds, acceleration: acceleration, time: time)
    }

    func magnitude() -> Double {
        return sqrt(pow(self.velocityX, 2) + pow(self.velocityY, 2) + pow(self.velocityZ, 2))
    }
}
