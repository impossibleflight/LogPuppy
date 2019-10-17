//
//  Destination.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

public protocol Destination {
	var system: String? { get }
	var category: String? { get }
	var levels: Level { get set }
	var formatter: Formatter { get }

	func log(entry: Entry)
	func rotate()

	func setting(category: String?) -> Self
}

extension Destination {
	func shouldLog(entry: Entry) -> Bool {
		guard levels != .none else { return false }
		guard levels.contains(Level(entry.level)) else { return false }
		return true
	}
}
