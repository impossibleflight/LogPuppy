//
//  OSLogDestination.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation
import os.log

public class OSLogDestination: Destination {
	public let system: String?
	public let category: String?
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
			os_log(osLogType(forLevel: entry.level), dso: entry.dso, log: log, "%{public}s", message)
		} else {
			os_log("%{public}s", dso: entry.dso, log: log, type: osLogType(forLevel: entry.level), message)
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

	public func rotate() {
		// os.log takes care of all this
	}

	public func setting(category newValue: String?) -> Self {
		return OSLogDestination(system: system, category: newValue, levels: levels) as! Self
	}

	private var log: OSLog
}
