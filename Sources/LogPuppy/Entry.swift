//
//  Entry.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

public struct Callsite {
	public let file: String
	public let function: String
	public let line: Int
	public let column: Int
}

public struct Entry {
	public var level: Level.RawValue
	public var format: String
	public var arguments: [CVarArg]
	public var dso: UnsafeRawPointer
	public var callsite: Callsite
	public var timestamp: Date

	init(level: Level.RawValue, format: String, args: [CVarArg] = [], dso: UnsafeRawPointer, callsite: Callsite, timestamp: Date = Date()) {
		self.level = level
		self.format = format
		self.arguments = args
		self.dso = dso
		self.callsite = callsite
		self.timestamp = timestamp
	}
}
