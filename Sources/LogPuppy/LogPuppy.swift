//
//  Logger.swift
//  LogPuppy
//
//  Created by John Clayton on 3/3/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation
import os.log


public final class Logger {
	public var destinations: [Destination]
	public init(destinations: [Destination]) {
		self.destinations = destinations
	}

	public func log(_ levels: Level = .default, _ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(levels, format, file: file, function: function, line: line, column: column, arguments: args)
	}

	public func log(_ levels: Level = .default, _ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, arguments: [CVarArg]) {
		let callsite = Callsite(file: file, function: function, line: line, column: column)
		for level in levels {
			let entry = Entry(level: level.rawValue, format: format, args: arguments, callsite: callsite)
			log(entry: entry)
		}
	}

	private func log(entry: Entry) {
		for destination in destinations where destination.shouldLog(entry: entry) {
			destination.log(entry: entry)
		}
	}

	private static var _defaultLogger: Logger?
	private static var _infoLogger: Logger?
	private static var _debugLogger: Logger?
}

extension Logger {
	public func `default`(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.default, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func info(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.info, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func debug(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.debug, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func error(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.error, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func fault(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.fault, format, file: file, function: function, line: line, column: column, arguments: args)
	}
}

extension Logger {
	public func `default`(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.default, message, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.info, message, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.debug, message, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.error, message, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.fault, message, file: file, function: function, line: line, column: column, arguments: [])
	}
}

extension Logger {
	public func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.error, "%@", file: file, function: function, line: line, column: column, arguments: [String(describing: error)])
	}
}

extension Logger {
	public func measure(_ levels: Level = .default, _ label: String = #function, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, closure: ()->Void) {
		let callback = timeBeacon(levels, label, file: file, function: function, line: line, column: column)
		closure()
		callback()
	}

	/// Measure the code in the supplied closure waiting for the block to call the measurement callback before registering an end to the work and measuring the time it took.
	///
	/// - Parameters:
	///   - levels: <#levels description#>
	///   - label: <#label description#>
	///   - file: <#file description#>
	///   - function: <#function description#>
	///   - line: <#line description#>
	///   - column: <#column description#>
	///   - closure: <#closure description#>
	public func measureAsync(_ levels: Level = .default, _ label: String = #function, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, closure: (@escaping MeasumentBeacon)->Void) {
		let callback = timeBeacon(levels, label, file: file, function: function, line: line, column: column)
		closure(callback)
	}

	public typealias MeasumentBeacon = ()->Void
	public func timeBeacon(_ levels: Level = .default, _ label: String = #function, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) -> MeasumentBeacon {
		let message = "Started { \(label) }"
		log(levels, message, file: file, function: function, line: line, column: column, arguments: [])
		let start = CFAbsoluteTimeGetCurrent()
		let callback = { [weak self] in
			let elapsed = CFAbsoluteTimeGetCurrent()-start;
			let message = "Completed { \(label) } - \(elapsed)s"
			self?.log(levels, message, file: file, function: function, line: line, column: column, arguments: [])
		}
		return callback
	}

}

extension Logger {
	private static func bundle(forDso dso: UnsafeRawPointer) -> Bundle? {
		var dlInformation : dl_info = dl_info()
		let _ = dladdr(dso, &dlInformation)
		let path = String(cString: dlInformation.dli_fname)
		let url = URL(fileURLWithPath: path).deletingLastPathComponent()
		let bundle = Bundle(url: url)
		return bundle
	}
}

extension Logger {
	public static func defaultLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		if _defaultLogger == nil {
			let calleeBundle = bundle(forDso: dso)
			let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: .default)
			_defaultLogger = Logger(destinations: [destination])
		}
		return _defaultLogger!
	}
	public static func `default`(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, args: CVarArg...) {
		defaultLogger().log(.default, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public static func infoLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		if _infoLogger == nil {
			let calleeBundle = bundle(forDso: dso)
			let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: .info)
			_infoLogger = Logger(destinations: [destination])
		}
		return _infoLogger!
	}
	public static func info(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, args: CVarArg...) {
		infoLogger().log(.default, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public static func debugLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		if _debugLogger == nil {
			let calleeBundle = bundle(forDso: dso)
			let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: [.debug])
			_debugLogger = Logger(destinations: [destination])
		}
		return _debugLogger!
	}
	public static func debug(_ format: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, args: CVarArg...) {
		debugLogger().log(.default, format, file: file, function: function, line: line, column: column, arguments: args)
	}
	public static func errorLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let calleeBundle = bundle(forDso: dso)
		let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: [.error, .fault])
		return Logger(destinations: [destination])
	}
	public static func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		errorLogger().error(error)
	}
}

extension Logger {
	public static func `for`(_ type: Any.Type, levels: Level, dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let calleeBundle = bundle(forDso: dso)
		let category = String(describing: type)
		let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: category, levels: levels)
		return Logger(destinations: [destination])
	}
	public static func `for`(_ category: String, levels: Level, dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let calleeBundle = bundle(forDso: dso)
		let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: category, levels: levels)
		return Logger(destinations: [destination])
	}
}

public struct Level: OptionSet, Sequence {
	public typealias RawValue = UInt
	public let rawValue: UInt

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	public init(_ rawValue: RawValue) {
		self.init(rawValue: rawValue)
	}

	public static let none = Level(0)
	public static let `default` = Level(1 << 0)
	public static let info = Level(1 << 1)
	public static let debug = Level(1 << 2)
	public static let error = Level(1 << 3)
	public static let fault = Level(1 << 4)

	public static let all: Level = [.default, .info, .debug, .error, .fault]
}

public struct Callsite {
	let file: String
	let function: String
	let line: Int
	let column: Int
}


public struct Entry {
	var level: Level.RawValue
	var format: String
	var arguments: [CVarArg]
	var callsite: Callsite

	init(level: Level.RawValue, format: String, args: [CVarArg] = [], callsite: Callsite) {
		self.level = level
		self.format = format
		self.arguments = args
		self.callsite = callsite
	}
}

public protocol Formatter {
	func format(_ entry: Entry, forDestination destination: Destination) -> String
}

public struct DefaultFormatter: Formatter {
	public func format(_ entry: Entry, forDestination destination: Destination) -> String {
		let message = String(format: entry.format, arguments: entry.arguments)
		if let system = destination.system, let category = destination.category {
			return String(format: "%@ [%@] %@", system, category, message)
		} else if let category = destination.category {
			return String(format: "[%@] %@", category, message)
		} else {
			return String(format: "%@", message)
		}
	}
}

public struct SimpleFormatter: Formatter {
	public init() {}
	public func format(_ entry: Entry, forDestination destination: Destination) -> String {
		let format = entry.format
		let args: [CVarArg] = entry.arguments
		let message = String(format: format, arguments: args)
		return message
	}
}

public protocol Destination {
	var system: String? { get }
	var category: String? { get }
	var levels: Level { get }
	var formatter: Formatter { get }

	func log(entry: Entry)
}

extension Destination {
	func shouldLog(entry: Entry) -> Bool {
		guard levels != .none else { return false }
		guard levels.contains(Level(entry.level)) else { return false }
		return true
	}
}

public class OSLogDestination: Destination {
	public var system: String?
	public var category: String?
	public var levels: Level
	public let formatter: Formatter = SimpleFormatter()

	public init(system: String?, category: String?, levels: Level) {
		self.system = system
		self.category = category
		self.levels = levels

		if let system = system, let category = category {
			log = OSLog(subsystem: system, category: category)
		} else {
			log = OSLog.default
		}
	}

	public func log(entry: Entry) {
		let message = formatter.format(entry, forDestination: self)
		if #available(iOS 12.0, *) {
			os_log(osLogType(forLevel: entry.level), log: log, "%{public}s", message)
		} else {
			os_log("%{public}s", log: log, type: osLogType(forLevel: entry.level), message)
		}
	}

	private func osLogType(forLevel level: Level.RawValue) -> OSLogType {
		switch level {
		case Level.default.rawValue:
			return .default
		case Level.info.rawValue:
			return .info
		case Level.debug.rawValue:
			return .debug
		case Level.error.rawValue:
			return .error
		case Level.fault.rawValue:
			return .fault
		default: return .default
		}
	}

	private var log: OSLog
}

public class OutputStreamDestination<Target: TextOutputStream>: Destination {
	public var system: String?
	public var category: String?
	public var levels: Level
	public var formatter: Formatter = DefaultFormatter()

	public init(system: String?, category: String?, levels: Level, outputStream: inout Target) {
		self.system = system ?? String(format: "%@[%@]", ProcessInfo.processInfo.processName, ProcessInfo.processInfo.processIdentifier)
		self.category = category
		self.levels = levels
		self.outputStream = outputStream
	}

	public func log(entry: Entry) {
		let message = formatter.format(entry, forDestination: self)
		message.write(to: &outputStream)
	}

	private var outputStream: Target
}

