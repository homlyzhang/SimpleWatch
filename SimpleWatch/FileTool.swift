//
//  FileTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 5/2/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation

class FileTool {

    static let lineSeperator = "\n"

    static func appendToFile(data: Data, file: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            //writing
            if let fileHandle = FileHandle(forWritingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
            else {
                do {
                    try data.write(to: url, options: Data.WritingOptions.atomic)
                }
                catch {/* error handling here */}
            }
        }
    }

    static func appendToFile(data: Data) {
        appendToFile(data: data, file: "file.txt")
    }

    static func appendTextToFile(text: String, file: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            //writing
            if let fileHandle = FileHandle(forWritingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(text.data(using: String.Encoding.utf8)!)
            }
            else {
                do {
                    try text.write(to: url, atomically: false, encoding: String.Encoding.utf8)
                }
                catch {/* error handling here */}
            }
        }
    }

    static func appendTextToFile(_ text: String) {
        appendTextToFile(text: text, file: "file.txt")
    }

    static func readFromFile(_ file: String) -> String {
        var text = ""
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(file)
            //reading
            do {
                text = try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}
        }
        return text
    }
    
    static func readFromFile(file: String, lastRows: Int) -> String {
        var result = ""
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            
            if let fileHandle = FileHandle(forReadingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                var data: Data
                var readText: String
                var textArray: [String]
                
                let end = fileHandle.seekToEndOfFile()
                fileHandle.seek(toFileOffset: end - 100)
                data = fileHandle.readDataToEndOfFile()
                readText = String(data: data, encoding: .utf8)!
                textArray = readText.components(separatedBy: lineSeperator)
                textArray.removeLast()
                let lineLength = textArray.last!.characters.count
                
                fileHandle.seek(toFileOffset: end - UInt64((lineLength + 5) * lastRows))
                data = fileHandle.readDataToEndOfFile()
                readText = String(data: data, encoding: .utf8)!
                textArray = readText.components(separatedBy: lineSeperator)
                textArray.removeLast()
                while textArray.count > lastRows {
                    textArray.removeFirst()
                }
                result = textArray.joined(separator: lineSeperator)
            }
        }
        return result
    }

    static func readFromFile() -> String {
        return readFromFile("file.txt")
    }

    static func deleteFile(_ file: String) {
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            do {
                try fileManager.removeItem(at: url)
            } catch {
                NSLog(error.localizedDescription)
            }
        }
    }
}
