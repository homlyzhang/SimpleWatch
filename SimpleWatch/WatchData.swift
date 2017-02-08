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

public struct WatchData {
    public var accelerations = [NSDate : CMAcceleration]()
    public var rotationRates = [NSDate : CMRotationRate]()
    public var locations = [NSDate : CLLocation]()

    let convertTool = ConvertTool()
    public init() {}
    public init(_ data: [String : Any]) {
        if data["acceleration"] != nil {
            self.accelerations = convertTool.dictArrayToAccelerationArray(data["acceleration"] as! [NSDate: Dictionary<String, Double>])
        }
        if data["rotationRate"] != nil {
            self.rotationRates = convertTool.dictArrayToRotationRateArray(data["rotationRate"] as! [NSDate: Dictionary<String, Double>])
        }
        if data["location"] != nil {
            self.locations = convertTool.dictArrayToLocationArray(data["location"] as! [NSDate: Dictionary<String, Double>])
        }
    }

    private func appendToFile(_ dictArray: [NSDate : Dictionary<String, Double>], fileSuffix: String) {
        var data = Data()
        let returnData = "\n".data(using: .utf8)!
        var dateStr = "", timeStr = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        for (time, dict) in dictArray {
            timeStr = formatter.string(from: time as Date)
            let dateEndIndex = timeStr.index(timeStr.startIndex, offsetBy: 8)
            if dateStr == "" {
                dateStr = timeStr.substring(to: dateEndIndex)
            }
            let tempDictArray = [timeStr.substring(from: dateEndIndex): dict]
            do {
                data.append(try JSONSerialization.data(withJSONObject: tempDictArray, options: []))
                data.append(returnData)
            }
            catch {
                NSLog("JSON data error")
            }
        }
        if dateStr != "" {
            FileTool().appendToFile(data: data, file: dateStr + fileSuffix)
        }
    }

    func appendToFile() {
        let message = convertTool.makeSendMessage(accelerations: self.accelerations, rotationRates: self.rotationRates, locations: self.locations)
        for property in ["acceleration", "rotationRate", "location"] {
            appendToFile(message[property] as! [NSDate : Dictionary<String, Double>], fileSuffix: "_" + property + ".txt")
        }
    }
}
