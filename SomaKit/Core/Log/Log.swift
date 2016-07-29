//
//  Log.swift
//  SomaKit
//
//  Created by Anton on 12.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum LogLevel: UInt32, CustomStringConvertible {
    case Debug = 0x1
    case Info = 0x10
    case Warning = 0x100
    case Error = 0x1000
    
    public var description: String {
        get {
            switch self {
            case .Debug:
                return "Debug"
            case .Info:
                return "Info"
            case .Warning:
                return "Warning"
            case .Error:
                return "Error"
            }
        }
    }
}

public struct LogPriority: Equatable, CustomStringConvertible {
    private let logLevels: UInt32
    
    private init(logLevels: UInt32) {
        self.logLevels = logLevels
    }
    
    public func contain(logLevel: LogLevel) -> Bool {
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
    
    public static let Error = LogPriority(logLevels: LogLevel.Error.rawValue)
    
    public static let Info = LogPriority(logLevels: LogLevel.Info.rawValue | LogLevel.Warning.rawValue | LogLevel.Error.rawValue)
    
    public static let All = LogPriority(logLevels: LogLevel.Debug.rawValue | LogLevel.Info.rawValue
        | LogLevel.Warning.rawValue | LogLevel.Error.rawValue)
}

public func ==(lhs: LogPriority, rhs: LogPriority) -> Bool {
    return lhs.logLevels == rhs.logLevels
}

public protocol LogProcessor {
    func log(message: String, args: Any...)
}

public final class Log {
    public static func initialize(logProcessor: LogProcessor, logPriority: LogPriority) {
        guard logInstance != nil else {
            log(.Error, message: "Log already initialized")
            return
        }
        
        logInstance = Log(logProcessor: logProcessor, logPriority: logPriority)
        log(.Info, message: "Log initialized with processor: \(logProcessor.dynamicType) and log priority: \(logPriority)")
    }
    
    public static func log(logLevel: LogLevel, message: String, args: Any...) {
        guard let logInstance = logInstance else {
            Debug.fatalError("Log not initialized")
        }
        
        logInstance.log(logLevel, message: message, args: args)
    }
    
    private func log(logLevel: LogLevel, message: String, args: Any...) {
        guard logPriority.contain(logLevel) else {
            return
        }
        
        let messageWithType = logPriority.description + ": " + message
        logProcessor.log(messageWithType, args: args)
    }
    
    private init(logProcessor: LogProcessor, logPriority: LogPriority) {
        self.logProcessor = logProcessor
        self.logPriority = logPriority
    }
    
    private static var logInstance: Log?
    
    private let logProcessor: LogProcessor
    
    private let logPriority: LogPriority
}
