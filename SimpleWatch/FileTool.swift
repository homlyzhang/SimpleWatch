//
//  FileTool.swift
//  SimpleWatch
//
//  Created by Homly ZHANG on 5/2/2017.
//  Copyright © 2017 Homly ZHANG. All rights reserved.
//

import Foundation

public struct FileTool {

    func appendToFile(data: Data, file: String) {
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

    func appendToFile(data: Data) {
        appendToFile(data: data, file: "file.txt")
    }

    func appendTextToFile(text: String, file: String) {
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

    func appendTextToFile(_ text: String) {
        appendTextToFile(text: text, file: "file.txt")
    }

    func readFromFile(_ file: String) -> String {
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

    func readFromFile() -> String {
        return readFromFile("file.txt")
    }
}
