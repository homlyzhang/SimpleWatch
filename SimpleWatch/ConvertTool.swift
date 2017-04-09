//
//  ConvertTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 28/11/2016.
//  Copyright © 2016 Homly ZHANG. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

class ConvertTool {

    static func accelerationToDict(_ acceleration: CMAcceleration) -> Dictionary<String, Double> {
        return ["x": acceleration.x, "y": acceleration.y, "z": acceleration.z]
    }

    static func accelerationDictToDictDict(_ accelerations: [NSDate : CMAcceleration]) -> [NSDate : Dictionary<String, Double>] {
        var result = [NSDate : Dictionary<String, Double>]()
        for (time, acce) in accelerations {
            result[time] = accelerationToDict(acce)
        }
        return result
    }

    static func rotationRateToDict(_ rotationRate: CMRotationRate) -> Dictionary<String, Double> {
        return ["x": rotationRate.x, "y": rotationRate.y, "z": rotationRate.z]
    }

    static func rotationRateDictToDictDict(_ rotationRates: [NSDate : CMRotationRate]) -> [NSDate : Dictionary<String, Double>] {
        var result = [NSDate : Dictionary<String, Double>]()
        for (time, roRate) in rotationRates {
            result[time] = rotationRateToDict(roRate)
        }
        return result
    }

    static func locationToDict(_ location: CLLocation) -> Dictionary<String, Double> {
        return ["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude, "altitude": location.altitude, "horizontalAccuracy": location.horizontalAccuracy, "verticalAccuracy": location.verticalAccuracy]
    }

    static func locationDictToDictDict(_ locations: [NSDate : CLLocation]) -> [NSDate : Dictionary<String, Double>] {
        var result = [NSDate : Dictionary<String, Double>]()
        for (time, location) in locations {
            result[time] = locationToDict(location)
        }
        return result
    }

    static func makeSendMessage(userAccelerations: [NSDate : CMAcceleration], accelerations: [NSDate : CMAcceleration], rotationRates: [NSDate : CMRotationRate], locations: [NSDate : CLLocation]) -> [String : Any] {
        var message = [String : Any]()
        if userAccelerations.count > 0 {
            message["userAcceleration"] = accelerationDictToDictDict(userAccelerations)
        }
        message["acceleration"] = accelerationDictToDictDict(accelerations)
        message["rotationRate"] = rotationRateDictToDictDict(rotationRates)
        message["location"] = locationDictToDictDict(locations)
        return message
    }

    static func makeSendMessage(accelerations: [NSDate : CMAcceleration], rotationRates: [NSDate : CMRotationRate], locations: [NSDate : CLLocation]) -> [String : Any] {
        return makeSendMessage(userAccelerations: [NSDate : CMAcceleration](), accelerations: accelerations, rotationRates: rotationRates, locations: locations)
    }

    static func makeSendMessage(deviceMotions: [NSDate : CMDeviceMotion], locations: [NSDate : CLLocation]) -> [String : Any] {
        var message = [String : Any]()
        var accelerationDict = [NSDate : Dictionary<String, Double>]()
        var userAccelerationDict = [NSDate : Dictionary<String, Double>]()
        var rotationRateDict = [NSDate : Dictionary<String, Double>]()
        for (time, motion) in deviceMotions {
            userAccelerationDict[time] = accelerationToDict(motion.userAcceleration)
            let totalAcceleration = CMAcceleration(x: motion.gravity.x + motion.userAcceleration.x, y: motion.gravity.y + motion.userAcceleration.y, z: motion.gravity.z + motion.userAcceleration.z)
            accelerationDict[time] = accelerationToDict(totalAcceleration)
            rotationRateDict[time] = rotationRateToDict(motion.rotationRate)
        }
        message["userAcceleration"] = userAccelerationDict
        message["acceleration"] = accelerationDict
        message["rotationRate"] = rotationRateDict
        message["location"] = locationDictToDictDict(locations)
        return message
    }

    static func dictToAcceleration(_ dict: Dictionary<String, Double>) -> CMAcceleration {
        return CMAcceleration(x: dict["x"]!, y: dict["y"]!, z: dict["z"]!)
    }

    static func dictArrayToAccelerationArray(_ dictArray: [NSDate : Dictionary<String, Double>]) -> [NSDate : CMAcceleration] {
        var result = [NSDate : CMAcceleration]()
        for (time, dict) in dictArray {
            result[time] = dictToAcceleration(dict)
        }
        return result
    }

    static func dictToRotationRate(_ dict: Dictionary<String, Double>) -> CMRotationRate {
        return CMRotationRate(x: dict["x"]!, y: dict["y"]!, z: dict["z"]!)
    }

    static func dictArrayToRotationRateArray(_ dictArray: [NSDate : Dictionary<String, Double>]) -> [NSDate : CMRotationRate] {
        var result = [NSDate : CMRotationRate]()
        for (time, dict) in dictArray {
            result[time] = dictToRotationRate(dict)
        }
        return result
    }

    static func dictToLocation(_ dict: Dictionary<String, Double>, timestamp: NSDate) -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: dict["latitude"]!, longitude: dict["longitude"]!), altitude: dict["altitude"]! as CLLocationDistance, horizontalAccuracy: dict["horizontalAccuracy"]!, verticalAccuracy: dict["verticalAccuracy"]!, timestamp: timestamp as Date)
    }

    static func dictArrayToLocationArray(_ dictArray: [NSDate : Dictionary<String, Double>]) -> [NSDate : CLLocation] {
        var result = [NSDate : CLLocation]()
        for (time, dict) in dictArray {
            result[time] = dictToLocation(dict, timestamp: time)
        }
        return result
    }

    static func stringToAccelerationsAndTime(fileText: String, dateStr: String) -> ([CMAcceleration], [Date], Date) {
        var result = [CMAcceleration]()
        var timeResult = [Date]()
        var lastTime = Date(timeIntervalSince1970: 0)
        var jsonStrArray = fileText.components(separatedBy: FileTool.lineSeperator)
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        
        for i in 0...jsonStrArray.count - 1 {
            let jsonStr = jsonStrArray[i]
            if jsonStr.characters.count > 0 {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonStr.data(using: .utf8)!, options: [])
                    let dict = json as! Dictionary<String, Dictionary<String, Double>>
                    for timeStr in dict.keys.sorted() {
                        let dictIn = dict[timeStr]!
                        let acceleration = ConvertTool.dictToAcceleration(dictIn)
                        result.append(acceleration)
                        let time = fullFormatter.date(from: "\(dateStr)\(timeStr)")!
                        timeResult.append(time)
                        lastTime = time
                    }
                } catch {
                    LogTool.log(error, #file, #function, #line)
                }
            }
        }
        return (result, timeResult, lastTime)
    }

    static func stringToAccelerations(fileText: String, dateStr: String) -> ([CMAcceleration], Date) {
        let result: [CMAcceleration]
        let lastTime: Date
        (result, _, lastTime) = stringToAccelerationsAndTime(fileText: fileText, dateStr: dateStr)
        return (result, lastTime)
    }

    static func stringToLocations(fileText: String, dateStr: String, accuracyThreshold: Double = 100) -> [CLLocation] {
        var result = [CLLocation]()
        var jsonStrArray = fileText.components(separatedBy: FileTool.lineSeperator)
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        
        for i in 0...jsonStrArray.count - 1 {
            let jsonStr = jsonStrArray[i]
            if jsonStr.characters.count > 0 {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonStr.data(using: .utf8)!, options: [])
                    let dict = json as! Dictionary<String, Dictionary<String, Double>>
                    for timeStr in dict.keys.sorted() {
                        let dictIn = dict[timeStr]!
                        let timestamp = fullFormatter.date(from: "\(dateStr)\(timeStr)")
                        let location = ConvertTool.dictToLocation(dictIn, timestamp: timestamp! as NSDate)
                        if location.horizontalAccuracy >= 0 && location.verticalAccuracy >= 0 && location.horizontalAccuracy <= accuracyThreshold && location.verticalAccuracy <= accuracyThreshold {
                            result.append(location)
                        } else {
                            LogTool.log("location invalid: \(location)")
                        }
                    }
                } catch {
                    LogTool.log(error, #file, #function, #line)
                }
            }
        }
        return result
    }
}
