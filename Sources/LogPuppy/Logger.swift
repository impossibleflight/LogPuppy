//
//  Logger.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

public typealias MeasurementBeacon = ()->Void

public protocol Logging {
	func log(_ levels: Level, _ format: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
	func log(_ levels: Level, _ format: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, _ args: CVarArg...)
	func log(_ levels: Level, _ format: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, arguments: [CVarArg])
}

public protocol ConvenienceLogging {
	func `default`(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, _ args: CVarArg...)
	func info(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, _ args: CVarArg...)
	func debug(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, _ args: CVarArg...)
	func error(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, _ args: CVarArg...)
	func fault(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, _ args: CVarArg...)

	func `default`(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
	func info(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
	func debug(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
	func error(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
	func fault(_ message: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
}

public protocol ErrorLogging {
	func error(_ error: Error, callStack: [String]?, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
	func fault(_ error: Error, callStack: [String], dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int)
}

public protocol Benchmarking {
	func measure(_ levels: Level, _ label: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, closure: ()->Void)
	func measureAsync(_ levels: Level, _ label: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int, closure: (@escaping MeasurementBeacon)->Void)
	func timeBeacon(_ levels: Level, _ label: String, dso: UnsafeRawPointer, file: String, function: String, line: Int, column: Int) -> MeasurementBeacon
}

open class Logger: Logging {
	public var destinations: [Destination]
	public init(destinations: [Destination]) {
		self.destinations = destinations
	}

	public func log(_ levels: Level = .default, _ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(levels, format, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
	}

	public func log(_ levels: Level = .default, _ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(levels, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}

	public func log(_ levels: Level = .default, _ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, arguments: [CVarArg]) {
		let callsite = Callsite(file: file, function: function, line: line, column: column)
		for level in levels {
			let entry = Entry(level: level.rawValue, format: format, args: arguments, dso: dso, callsite: callsite)
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

//MARK: ConvenienceLogging
extension Logger: ConvenienceLogging {
	public func `default`(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.default, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func info(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.info, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func debug(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.debug, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func error(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.error, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public func fault(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, _ args: CVarArg...) {
		log(.fault, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}

	public func `default`(_ message: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.default, message, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func info(_ message: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.info, message, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func debug(_ message: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.debug, message, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func error(_ message: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.error, message, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
	}
	public func fault(_ message: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		log(.fault, message, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
	}
}

//MARK: ErrorLogging
extension Logger: ErrorLogging {
	public func error(_ error: Error, callStack: [String]? = nil, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		var message = String(describing: error)
		if let stack = callStack {
			message += "\n"
			message += stack.joined(separator: "\n")
		}
		log(.error, message, dso: dso, file: file, function: function, line: line, column: column)
	}

	public func fault(_ error: Error, callStack: [String] = Thread.callStackSymbols, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		let message = 	"""
						\(String(describing: error))
						\(callStack.joined(separator: "\n"))
						"""
		log(.error, message, dso: dso, file: file, function: function, line: line, column: column)
	}
}

//MARK: Benchmarking
extension Logger: Benchmarking {
	public func measure(_ levels: Level = .default, _ label: String = #function, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, closure: ()->Void) {
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
	public func measureAsync(_ levels: Level = .default, _ label: String = #function, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, closure: (@escaping MeasurementBeacon)->Void) {
		let callback = timeBeacon(levels, label, file: file, function: function, line: line, column: column)
		closure(callback)
	}

	public func timeBeacon(_ levels: Level = .default, _ label: String = #function, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) -> MeasurementBeacon {
		let identifier = UUID()
		let message = "Started (\(identifier)) { \(label) }"
		log(levels, message, file: file, function: function, line: line, column: column, arguments: [])
		let start = CFAbsoluteTimeGetCurrent()
		let callback = { [weak self] in
			let elapsed = CFAbsoluteTimeGetCurrent()-start;
			let message = "Completed (\(identifier)) { \(label) } - \(elapsed)s"
			self?.log(levels, message, dso: dso, file: file, function: function, line: line, column: column, arguments: [])
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
	public static func `default`(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, args: CVarArg...) {
		defaultLogger(dso: dso).log(.default, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public static func infoLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		if _infoLogger == nil {
			let calleeBundle = bundle(forDso: dso)
			let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: .info)
			_infoLogger = Logger(destinations: [destination])
		}
		return _infoLogger!
	}
	public static func info(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, args: CVarArg...) {
		infoLogger(dso: dso).log(.default, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public static func debugLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		if _debugLogger == nil {
			let calleeBundle = bundle(forDso: dso)
			let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: [.debug])
			_debugLogger = Logger(destinations: [destination])
		}
		return _debugLogger!
	}
	public static func debug(_ format: String, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, args: CVarArg...) {
		debugLogger(dso: dso).log(.default, format, dso: dso, file: file, function: function, line: line, column: column, arguments: args)
	}
	public static func errorLogger(dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let calleeBundle = bundle(forDso: dso)
		let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: nil, levels: [.error, .fault])
		return Logger(destinations: [destination])
	}
	public static func error(_ error: Error, dso: UnsafeRawPointer = #dsohandle, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
		errorLogger(dso: dso).error(error, dso: dso, file: file, function: function, line: line, column: column)
	}
}

extension Logger {
	public static func `for`(_ type: Any.Type, levels: Level, dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let category = String(describing: type)
		return Logger.for(category, levels: levels, dso: dso)
	}
	public static func `for`(_ category: String, levels: Level, dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let calleeBundle = bundle(forDso: dso)
		let destination = OSLogDestination(system: calleeBundle?.bundleIdentifier, category: category, levels: levels)
		return Logger(destinations: [destination])
	}
}

public extension Logger {
	func `for`(_ type: Any.Type, dso: UnsafeRawPointer = #dsohandle) -> Logger {
		let category = String(describing: type)
		return self.setting(category: category, dso: dso)
	}
	func setting(category newValue: String, dso: UnsafeRawPointer = #dsohandle) -> Logger {
		var destinationsForCategory = [Destination]()
		for destination in destinations {
			destinationsForCategory.append(destination.setting(category: newValue))
		}
		return Logger(destinations: destinationsForCategory)
	}
}
