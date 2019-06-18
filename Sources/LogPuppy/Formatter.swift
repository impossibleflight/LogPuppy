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
	public init() {}
	public func format(_ entry: Entry, forDestination destination: Destination) -> String {
		let message = String(format: entry.format, arguments: entry.arguments)
		let level = Level(entry.level).name
		if let system = destination.system, let category = destination.category {
			return String(format: "%@ %@ [%@] %@", system, level, category, message)
		} else if let category = destination.category {
			return String(format: "%@ [%@] %@", level, category, message)
		} else {
			return String(format: "%@ %@", level, message)
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
