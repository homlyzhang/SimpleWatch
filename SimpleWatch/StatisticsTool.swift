//
//  StatisticsTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 4/3/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation
import CoreLocation

class StatisticsTool {

//    private distanceCache =

    static func getSecondLocations(_ oriLocations: [CLLocation]) -> [CLLocation] {
        var secondLocations = [CLLocation]()
        if oriLocations.count == 1 {
            secondLocations.append(oriLocations[0])
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
                    sumDict["latitude"] = sumDict["latitude"]! + curLoc.coordinate.latitude
                    sumDict["longitude"] = sumDict["longitude"]! + curLoc.coordinate.longitude
                    sumDict["altitude"] = sumDict["altitude"]! + curLoc.altitude
                    sumDict["interval"] = sumDict["interval"]! + curLoc.timestamp.timeIntervalSince1970
                }
            }
        }
        return secondLocations
    }

    static func distance(_ locations: [CLLocation]) -> Double {
        var d = 0.0
        let secLoc = getSecondLocations(locations)
        for i in 0...secLoc.count - 2 {
            d = d + secLoc[i + 1].distance(from: secLoc[i])
        }
        return d
    }
//
//    static func distance(_ date: Date) -> Double {
//        var d = 0.0
//        return
//    }
}
