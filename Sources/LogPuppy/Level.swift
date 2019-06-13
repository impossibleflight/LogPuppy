//
//  Level.swift
//  LogPuppy
//
//  Created by John Clayton on 6/13/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

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


