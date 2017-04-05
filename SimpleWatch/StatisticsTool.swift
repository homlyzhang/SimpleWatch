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
            if curLoc.horizontalAccuracy >= 0 && curLoc.verticalAccuracy >= 0 {
                secondLocations.append(curLoc)
            } else {
                LogTool.log("location invalid: \(curLoc)")
            }
        }
        if oriLocations.count > 1 {
            var startIndex = 0
            var curSecInterval = Int(oriLocations[0].timestamp.timeIntervalSince1970)
            var sumDict = ConvertTool.locationToDict(oriLocations[0])
            sumDict["interval"] = oriLocations[0].timestamp.timeIntervalSince1970
            for i in 1...oriLocations.count {
                if i == oriLocations.count || curSecInterval != Int(oriLocations[i].timestamp.timeIntervalSince1970) {
                    let times = Double(i - startIndex)
                    sumDict["latitude"] = sumDict["latitude"]! / times
                    sumDict["longitude"] = sumDict["longitude"]! / times
                    sumDict["altitude"] = sumDict["altitude"]! / times
                    sumDict["interval"] = sumDict["interval"]! / times
                    sumDict["horizontalAccuracy"] = sumDict["horizontalAccuracy"]! / times
                    sumDict["verticalAccuracy"] = sumDict["verticalAccuracy"]! / times

                    let tempNSDate = NSDate(timeIntervalSince1970: sumDict["interval"]!)
                    let tempLocation = ConvertTool.dictToLocation(sumDict, timestamp: tempNSDate)
                    secondLocations.append(tempLocation)
                    if i < oriLocations.count {
                        let curLoc = oriLocations[i]
                        startIndex = i
                        curSecInterval = Int(curLoc.timestamp.timeIntervalSince1970)
                        sumDict = ConvertTool.locationToDict(curLoc)
                        sumDict["interval"] = curLoc.timestamp.timeIntervalSince1970
                    }
                } else if i < oriLocations.count {
                    let curLoc = oriLocations[i]
                    if curLoc.horizontalAccuracy >= 0 && curLoc.verticalAccuracy >= 0 {
                        sumDict["latitude"] = sumDict["latitude"]! + curLoc.coordinate.latitude
                        sumDict["longitude"] = sumDict["longitude"]! + curLoc.coordinate.longitude
                        sumDict["altitude"] = sumDict["altitude"]! + curLoc.altitude
                        sumDict["interval"] = sumDict["interval"]! + curLoc.timestamp.timeIntervalSince1970
                        sumDict["horizontalAccuracy"] = sumDict["horizontalAccuracy"]! + curLoc.horizontalAccuracy
                        sumDict["verticalAccuracy"] = sumDict["verticalAccuracy"]! + curLoc.verticalAccuracy
                    } else {
                        LogTool.log("location invalid: \(curLoc)")
                    }
                }
            }
        }
        return secondLocations
    }

    static func distance(_ locations: [CLLocation]) -> Double {
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
                if deltaD >= min(curLoc.horizontalAccuracy, curLoc.verticalAccuracy, preLocation.horizontalAccuracy, preLocation.verticalAccuracy) * 0.5 {
                    d = d + deltaD
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
