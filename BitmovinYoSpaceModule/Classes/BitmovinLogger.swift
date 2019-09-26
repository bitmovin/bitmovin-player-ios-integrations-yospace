//
//  BitmovinLogger.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 9/26/19.
//

import Foundation

// Enum which maps an appropiate symbol which added as prefix for each log message
//
// - error: Log type error
// - info: Log type info
// - debug: Log type debug
// - verbose: Log type verbose
// - warning: Log type warning
// - severe: Log type severe
enum LogEvent: String {
    case error = "[Error]"
    case info = "[Info]"
    case debug = "[Debug]"
    case verbose = "[Verbose]"
    case warning = "[Warning]"
    case severe = "[Severe]"
}

class BitmovinLogger {
    
    private static var isDebug = false
    
    class func enableLogging() {
        isDebug = true
    }
    
    class func disableLogging() {
        isDebug = false
    }
    
    class func e(message: String) {
        printLog(event: LogEvent.error, message: message)
    }
    
    class func i(message: String) {
        printLog(event: LogEvent.info, message: message)
    }
    
    class func d(message: String) {
        printLog(event: LogEvent.debug, message: message)
    }
    
    class func v(message: String) {
        printLog(event: LogEvent.verbose, message: message)
    }
    
    class func w(message: String) {
        printLog(event: LogEvent.warning, message: message)
    }
    
    class func s(message: String) {
        printLog(event: LogEvent.severe, message: message)
    }
    
    private class func printLog(event: LogEvent, message: String) {
        if isDebug {
            print("\(event.rawValue): \(message)")
        }
    }
}
