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
        return ["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude, "altitude": location.altitude]
    }

    static func locationDictToDictDict(_ locations: [NSDate : CLLocation]) -> [NSDate : Dictionary<String, Double>] {
        var result = [NSDate : Dictionary<String, Double>]()
        for (time, location) in locations {
            result[time] = locationToDict(location)
        }
        return result
    }

    static func makeSendMessage(accelerations: [NSDate : CMAcceleration], rotationRates: [NSDate : CMRotationRate], locations: [NSDate : CLLocation]) -> [String : Any] {
        var message = [String : Any]()
        message["acceleration"] = accelerationDictToDictDict(accelerations)
        message["rotationRate"] = rotationRateDictToDictDict(rotationRates)
        message["location"] = locationDictToDictDict(locations)
        return message
    }

    static func makeSendMessage(deviceMotions: [NSDate : CMDeviceMotion], locations: [NSDate : CLLocation]) -> [String : Any] {
        var message = [String : Any]()
        var accelerationDict = [NSDate : Dictionary<String, Double>]()
        var rotationRateDict = [NSDate : Dictionary<String, Double>]()
        for (time, motion) in deviceMotions {
            let totalAcceleration = CMAcceleration(x: motion.gravity.x + motion.userAcceleration.x, y: motion.gravity.y + motion.userAcceleration.y, z: motion.gravity.z + motion.userAcceleration.z)
            accelerationDict[time] = accelerationToDict(totalAcceleration)
            rotationRateDict[time] = rotationRateToDict(motion.rotationRate)
        }
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
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: dict["latitude"]!, longitude: dict["longitude"]!), altitude: dict["altitude"]! as CLLocationDistance, horizontalAccuracy: 0.0, verticalAccuracy: 0.0, timestamp: timestamp as Date)
    }

    static func dictArrayToLocationArray(_ dictArray: [NSDate : Dictionary<String, Double>]) -> [NSDate : CLLocation] {
        var result = [NSDate : CLLocation]()
        for (time, dict) in dictArray {
            result[time] = dictToLocation(dict, timestamp: time)
        }
        return result
    }
}
