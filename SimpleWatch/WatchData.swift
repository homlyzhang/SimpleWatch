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
    var accelerations = [NSDate : CMAcceleration]()
    var rotationRates = [NSDate : CMRotationRate]()
    var locations = [NSDate : CLLocation]()

    public init() {}
    public init(_ data: [String : Any]) {
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"

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
        let message = ConvertTool.makeSendMessage(accelerations: self.accelerations, rotationRates: self.rotationRates, locations: self.locations)
        for property in ["acceleration", "rotationRate", "location"] {
            appendToFile(message[property] as! [NSDate : Dictionary<String, Double>], fileSuffix: "_" + property + ".txt")
        }
    }

    static func getLatestLocations(date: Date, num: Int) -> [CLLocation] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: date)
        var lastRows: String
        if num >= 0 {
            lastRows = FileTool.read(from: dateStr + "_location.txt", lastRows: num)
        } else {
            lastRows = FileTool.read(dateStr + "_location.txt")
        }
        var jsonStrArray = lastRows.components(separatedBy: FileTool.lineSeperator)
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "yyyyMMddHHmmssSSS"

        var result = [CLLocation]()
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
                        result.append(location)
                    }
                } catch {
                    LogTool.log(error, #file, #function, #line)
                }
            }
        }
        return result
    }
}
