//
//  Formatter.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

public protocol Formatter {
	func format(_ entry: Entry, forDestination destination: Destination) -> String
}

public struct DefaultFormatter: Formatter {
	let dateFormatter: DateFormatter
	public init() {
		dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
	}
	public func format(_ entry: Entry, forDestination destination: Destination) -> String {
		let timestamp = dateFormatter.string(from: entry.timestamp)
		let level = Level(entry.level).name
		let message = String(format: entry.format, arguments: entry.arguments)
		if let system = destination.system, let category = destination.category {
			return String(format: "%@ %@ %@ [%@] %@", timestamp, system, level, category, message)
		} else if let category = destination.category {
			return String(format: "%@ %@ [%@] %@", timestamp, level, category, message)
		} else {
			return String(format: "%@ %@ %@", timestamp, level, message)
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
