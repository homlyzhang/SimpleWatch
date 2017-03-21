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

    static func append(data: Data, to file: String) {
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

    static func append(data: Data) {
        append(data: data, to: "file.txt")
    }

    static func appendText(text: String, to file: String) {
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

    static func appendText(_ text: String) {
        appendText(text: text, to: "file.txt")
    }

    static func readTextAndEnd(_ file: String) -> (String, UInt64) {
        var text = ""
        var end = UInt64(0)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            
            //reading
            if let fileHandle = FileHandle(forReadingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                end = fileHandle.seekToEndOfFile()
                do {
                    text = try String(contentsOf: url, encoding: String.Encoding.utf8)
                } catch {/* error handling here */}
            }
        }
        return (text, end)
    }
    
    static func read(_ file: String) -> String {
        let (text, _) = readTextAndEnd(file)
        return text
    }

    static func readTextAndEnd(from file: String, lastRows: Int) -> (String, UInt64) {
        var result = ""
        var end = UInt64(0)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            
            if let fileHandle = FileHandle(forReadingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                var data: Data
                var readText: String
                var textArray: [String]

                var offset: UInt64
                end = fileHandle.seekToEndOfFile()
                var tryLineLength = UInt64(100)
                repeat {
                    offset = UInt64(0)
                    if end >= tryLineLength {
                        offset = end - tryLineLength
                    }
                    fileHandle.seek(toFileOffset: offset)
                    data = fileHandle.readDataToEndOfFile()
                    readText = String(data: data, encoding: .utf8)!
                    textArray = readText.components(separatedBy: lineSeperator)
                    if textArray.last! == "" {
                        textArray.removeLast()
                    }
                    tryLineLength = tryLineLength * 2
                } while (textArray.count < lastRows + 1 && offset > 0)
                let lineLength = textArray.last!.characters.count
                
                offset = UInt64(0)
                if end >= UInt64((lineLength + 5) * lastRows) {
                    offset = end - UInt64((lineLength + 5) * lastRows)
                }
                fileHandle.seek(toFileOffset: offset)
                data = fileHandle.readDataToEndOfFile()
                readText = String(data: data, encoding: .utf8)!
                textArray = readText.components(separatedBy: lineSeperator)
                while textArray.count > lastRows {
                    textArray.removeFirst()
                }
                result = textArray.joined(separator: lineSeperator)
            }
        }
        return (result, end)
    }

    static func read(from file: String, lastRows: Int) -> String {
        let (data, _) = readTextAndEnd(from: file, lastRows: lastRows)
        return data
    }

    static func read(from file: String, beginWith offset: UInt64) -> String {
        var result = ""
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(file)
            
            if let fileHandle = FileHandle(forReadingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                var data: Data

                fileHandle.seek(toFileOffset: offset)
                data = fileHandle.readDataToEndOfFile()
                result = String(data: data, encoding: .utf8)!
            }
        }
        return result
    }
    
    static func readLine(from file: String, beginWith offset: UInt64) -> String {
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
                var tryLineLength = 50
                repeat {
                    fileHandle.seek(toFileOffset: offset)
                    tryLineLength = tryLineLength * 2
                    data = fileHandle.readData(ofLength: tryLineLength)
                    readText = String(data: data, encoding: .utf8)!
                    textArray = readText.components(separatedBy: lineSeperator)
                } while (textArray.count < 2 && offset + UInt64(tryLineLength) < end)
                
                result = textArray[0]
            }
        }
        return result
    }

    static func read() -> String {
        return read("file.txt")
    }

    static func delete(_ file: String) {
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
