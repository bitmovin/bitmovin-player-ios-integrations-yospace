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
    case e = "[Error]"
    case i = "[Info]"
    case d = "[Debug]"
    case v = "[Verbose]"
    case w = "[Warning]"
    case s = "[Severe]"
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
        if isDebug {
            print("\(LogEvent.e.rawValue): \(message)")
        }
    }
    
    class func i(message: String) {
        if isDebug {
            print("\(LogEvent.i.rawValue): \(message)")
        }
    }
    
    class func d(message: String) {
        if isDebug {
            print("\(LogEvent.d.rawValue): \(message)")
        }
    }
    
    class func v(message: String) {
        if isDebug {
            print("\(LogEvent.v.rawValue): \(message)")
        }
    }
    
    class func w(message: String) {
        if isDebug {
            print("\(LogEvent.w.rawValue): \(message)")
        }
    }
    
    class func s(message: String) {
        if isDebug {
            print("\(LogEvent.s.rawValue): \(message)")
        }
    }
}
