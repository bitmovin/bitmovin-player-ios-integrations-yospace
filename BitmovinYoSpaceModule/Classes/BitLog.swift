//
//  BitLog.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 9/26/19.
//

import Foundation

class BitLog {

    static var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    static var isEnabled = false

    class func d(_ message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(tag: "D", message: message, filename: filename, line: line, column: column, funcName: funcName)
    }

    class func e(_ message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(tag: "E", message: message, filename: filename, line: line, column: column, funcName: funcName)
    }

    class func i(_ message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(tag: "I", message: message, filename: filename, line: line, column: column, funcName: funcName)
    }

    class func v(_ message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(tag: "V", message: message, filename: filename, line: line, column: column, funcName: funcName)
    }

    class func w(_ message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(tag: "W", message: message, filename: filename, line: line, column: column, funcName: funcName)
    }

    class func s(_ message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(tag: "S", message: message, filename: filename, line: line, column: column, funcName: funcName)
    }

    //swiftlint:disable line_length
    private class func log(tag: String, message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isEnabled {
            print("\(Date().toString()) \(tag)/\(String(describing: self)): [\(extractFileFromPath(filePath: filename)):\(trimFunctionName(funcName: funcName)):\(line)] -> \(message)")
        }
    }
    //swiftlint:enable line_length

    private class func extractFileFromPath(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        if components.isEmpty {
            return ""
        } else {
            // Remove .swift from file name
            let fileName = components.last!
            return fileName.components(separatedBy: ".").first ?? fileName
        }
    }

    private class func trimFunctionName(funcName: String) -> String {
        // Remove () from function name
        return funcName.components(separatedBy: "(").first ?? funcName
    }
}

internal extension Date {
    func toString() -> String {
        return BitLog.dateFormatter.string(from: self as Date)
    }
}
