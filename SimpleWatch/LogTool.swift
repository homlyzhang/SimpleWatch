//
//  LogTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 8/3/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation

class LogTool {
    static func log(_ error: Error, _ filePath: String, _ functionName: String, _ lineNumber: Int) {
        NSLog("\(error.localizedDescription) \(NSString(string: NSString(string: filePath).lastPathComponent).deletingPathExtension) \(functionName)[\(lineNumber)]")
    }

    static func log(_ logMsg: String) {
        NSLog("\(logMsg)]")
    }
}
