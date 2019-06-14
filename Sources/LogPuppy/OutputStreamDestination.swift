//
//  OutputStreamDestination.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

public class OutputStreamDestination<Target: TextOutputStream>: Destination {
	public let system: String?
	public let category: String?
	public var levels: Level
	public let formatter: Formatter = DefaultFormatter()

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

	public func rotate() {
		// TODO: depends on what the stream represents
	}

	private var outputStream: Target
}
