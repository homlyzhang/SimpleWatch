//
//  StatisticsTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 4/3/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

class StatisticsTool {

    static func getSecondLocations(_ oriLocations: [CLLocation]) -> [CLLocation] {
        var secondLocations = [CLLocation]()
        if oriLocations.count == 1 {
            let curLoc = oriLocations[0]
            secondLocations.append(curLoc)
        }
        if oriLocations.count > 1 {
            var startIndex = 0
            var curSecInterval = Int(oriLocations[0].timestamp.timeIntervalSince1970)
            var temDict = ConvertTool.locationToDict(oriLocations[0])
            temDict["interval"] = oriLocations[0].timestamp.timeIntervalSince1970
            for i in 1...oriLocations.count {
                if i == oriLocations.count || curSecInterval != Int(oriLocations[i].timestamp.timeIntervalSince1970) {
                    let times = Double(i - startIndex)
                    temDict["latitude"] = temDict["latitude"]! / times
                    temDict["longitude"] = temDict["longitude"]! / times
                    temDict["altitude"] = temDict["altitude"]! / times
                    temDict["interval"] = temDict["interval"]! / times

                    let tempNSDate = NSDate(timeIntervalSince1970: temDict["interval"]!)
                    let tempLocation = ConvertTool.dictToLocation(temDict, timestamp: tempNSDate)
                    secondLocations.append(tempLocation)
                    if i < oriLocations.count {
                        let curLoc = oriLocations[i]
                        startIndex = i
                        curSecInterval = Int(curLoc.timestamp.timeIntervalSince1970)
                        temDict = ConvertTool.locationToDict(curLoc)
                        temDict["interval"] = curLoc.timestamp.timeIntervalSince1970
                    }
                } else if i < oriLocations.count {
                    let curLoc = oriLocations[i]
                    temDict["latitude"] = temDict["latitude"]! + curLoc.coordinate.latitude
                    temDict["longitude"] = temDict["longitude"]! + curLoc.coordinate.longitude
                    temDict["altitude"] = temDict["altitude"]! + curLoc.altitude
                    temDict["interval"] = temDict["interval"]! + curLoc.timestamp.timeIntervalSince1970
                    temDict["horizontalAccuracy"] = max(temDict["horizontalAccuracy"]!, curLoc.horizontalAccuracy)
                    temDict["verticalAccuracy"] = max(temDict["verticalAccuracy"]!, curLoc.verticalAccuracy)
                }
            }
        }
        return secondLocations
    }

    static func distance(_ locations: [CLLocation], accuracyCoeffcientThreshold: Double = 0.35, speedThreshold:Double = 300.0) -> Double {
        /*
         * common speed of an airplane is about 268 m/s, so the default speed threshold set to 300
         */
//        let time_start = Date()
        var d = 0.0
        var preLocation = CLLocation()
        let secLoc = getSecondLocations(locations)
        for i in 0...secLoc.count - 1 {
            if i == 0 {
                preLocation = secLoc[i]
            } else {
                let curLoc = secLoc[i]
                let deltaD = curLoc.distance(from: preLocation)
                let deltaSecond = curLoc.timestamp.timeIntervalSince1970 - preLocation.timestamp.timeIntervalSince1970
                let horizontalAccuracy = max(curLoc.horizontalAccuracy, preLocation.horizontalAccuracy)
                let verticalAccuracy = max(curLoc.verticalAccuracy, preLocation.verticalAccuracy)
                if deltaD >= horizontalAccuracy * accuracyCoeffcientThreshold && deltaD >= verticalAccuracy * accuracyCoeffcientThreshold {
                    if deltaD <= speedThreshold * deltaSecond {
//                        print("deltaD: \(deltaD), deltaSecond: \(deltaSecond), horizontalAccuracy: \(horizontalAccuracy), verticalAccuracy: \(verticalAccuracy)")
                        d = d + deltaD
                    }
                    preLocation = curLoc
                }
            }
        }
//        print("distance: \(d)m, \(((Date().timeIntervalSince1970 - time_start.timeIntervalSince1970) * 1000).rounded() / 1000)s, \(locations.count) locations")
        return d
    }

    static func pedometer(_ accelerations: [CMAcceleration], walkThreshold: Double, runThreshold: Double) -> (Int, Int) {
        let time_start = Date()
        var walkNum = 0
        var runNum = 0
        for i in 0...accelerations.count - 1 {
            let curAcc = accelerations[i]
            let mag = sqrt(pow(curAcc.x, 2) + pow(curAcc.y, 2) + pow(curAcc.z, 2))
            if mag >= walkThreshold && mag < runThreshold {
                walkNum += 1
            } else if mag >= runThreshold {
                runNum += 1
            }
        }
        print("walk: \(walkNum) steps, run: \(runNum) steps, \(((Date().timeIntervalSince1970 - time_start.timeIntervalSince1970) * 1000).rounded() / 1000)s, \(accelerations.count) accelerations")
        return (walkNum, runNum)
    }

    static func pedometer(_ accelerations: [CMAcceleration]) -> (Int, Int) {
        return pedometer(accelerations, walkThreshold: 1.28394, runThreshold: 1.64500)
    }
}
