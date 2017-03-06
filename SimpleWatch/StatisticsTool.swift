//
//  StatisticsTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 4/3/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation
import CoreLocation

public struct StatisticsTool {

    let convertTool = ConvertTool()

    func getSecondLocations(_ oriLocations: [CLLocation]) -> [CLLocation] {
        var secondLocations = [CLLocation]()
        if oriLocations.count == 1 {
            secondLocations.append(oriLocations[0])
        }
        if oriLocations.count > 1 {
            var lastIndex = -1
            var lastSecInterval = Int(oriLocations[0].timestamp.timeIntervalSince1970)
            var sumDict = convertTool.locationToDict(oriLocations[0])
            sumDict["interval"] = oriLocations[0].timestamp.timeIntervalSince1970
            for i in 1...oriLocations.count {
                if i == oriLocations.count || lastSecInterval != Int(oriLocations[i].timestamp.timeIntervalSince1970) {
                    let times = Double(i - lastIndex)
                    sumDict["latitude"] = sumDict["latitude"]! / times
                    sumDict["longitude"] = sumDict["longitude"]! / times
                    sumDict["altitude"] = sumDict["altitude"]! / times
                    sumDict["interval"] = sumDict["interval"]! / times
                    let tempNSDate = NSDate(timeIntervalSince1970: sumDict["interval"]!)
                    let tempLocation = convertTool.dictToLocation(sumDict, timestamp: tempNSDate)
                    secondLocations.append(tempLocation)
                    if i < oriLocations.count {
                        let curLoc = oriLocations[i]
                        lastIndex = i
                        lastSecInterval = Int(curLoc.timestamp.timeIntervalSince1970)
                        sumDict = convertTool.locationToDict(curLoc)
                        sumDict["interval"] = curLoc.timestamp.timeIntervalSince1970
                    }
                }

                if i < oriLocations.count {
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

    func distance(_ locations: [CLLocation]) -> Double {
        var d = 0.0
        
        return d
    }
}
