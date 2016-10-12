//
//  Log.swift
//  SomaKit
//
//  Created by Anton on 12.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum LogLevel: UInt32, CustomStringConvertible {
    case debug = 0x1
    case info = 0x10
    case warning = 0x100
    case error = 0x1000
    
    public var description: String {
        get {
            switch self {
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            }
        }
    }
}

public struct LogPriority: Equatable, CustomStringConvertible {
    fileprivate let logLevels: UInt32
    
    fileprivate init(logLevels: UInt32) {
        self.logLevels = logLevels
    }
    
    public func contain(_ logLevel: LogLevel) -> Bool {
        return logLevels & logLevel.rawValue == 1
    }
    
    public var description: String {
        get {
            switch self {
            case LogPriority.None:
                return "None"
            case LogPriority.Error:
                return "Error"
            case LogPriority.Info:
                return "Info"
            case LogPriority.All:
                return "All"
            default:
                Debug.fatalError("Unknown log priority")
            }
        }
    }
    
    public static let None = LogPriority(logLevels: 0)
    
    public static let Error = LogPriority(logLevels: LogLevel.error.rawValue)
    
    public static let Info = LogPriority(logLevels: LogLevel.info.rawValue | LogLevel.warning.rawValue | LogLevel.error.rawValue)
    
    public static let All = LogPriority(logLevels: LogLevel.debug.rawValue | LogLevel.info.rawValue
        | LogLevel.warning.rawValue | LogLevel.error.rawValue)
}

public func ==(lhs: LogPriority, rhs: LogPriority) -> Bool {
    return lhs.logLevels == rhs.logLevels
}

public protocol LogProcessor {
    func log(_ message: String, args: Any...)
}

public final class Log {
    public static func initialize(_ logProcessor: LogProcessor, logPriority: LogPriority) {
        logInstance = Log(logProcessor: logProcessor, logPriority: logPriority)
        log(.info, message: "Log initialized with processor: \(type(of: logProcessor)) and log priority: \(logPriority)")
    }
    
    public static func initialize(_ logPriority: LogPriority) {
        initialize(logInstance.logProcessor, logPriority: logPriority)
    }
    
    public static func log(_ logLevel: LogLevel, message: String, args: Any...) {
        logInstance.log(logLevel, message: message, args: args)
    }
    
    fileprivate func log(_ logLevel: LogLevel, message: String, args: Any...) {
        guard logPriority.contain(logLevel) else {
            return
        }
        
        let messageWithType = logPriority.description + ": " + message
        logProcessor.log(messageWithType, args: args)
    }
    
    fileprivate init(logProcessor: LogProcessor, logPriority: LogPriority) {
        self.logProcessor = logProcessor
        self.logPriority = logPriority
    }
    
    fileprivate static var logInstance: Log = Log(logProcessor: NativeLogProcessor(), logPriority: .Info)
    
    fileprivate let logProcessor: LogProcessor
    
    fileprivate let logPriority: LogPriority
}
