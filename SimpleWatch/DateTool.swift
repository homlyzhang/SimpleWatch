//
//  DateTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 5/4/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation

class DateTool {

    static func getDateFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }

    static func getMillSecFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        return formatter
    }

    static func getSecondFullFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}
