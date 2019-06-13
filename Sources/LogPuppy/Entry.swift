//
//  Entry.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

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
	var dso: UnsafeRawPointer
	var callsite: Callsite

	init(level: Level.RawValue, format: String, args: [CVarArg] = [], dso: UnsafeRawPointer, callsite: Callsite) {
		self.level = level
		self.format = format
		self.arguments = args
		self.dso = dso
		self.callsite = callsite
	}
}
