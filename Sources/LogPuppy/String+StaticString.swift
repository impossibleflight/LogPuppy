//
//  String+StaticString.swift
//  LogPuppy
//
//  Created by John Clayton on 3/4/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation

extension String {
	init(_ staticString: StaticString) {
		self = staticString.withUTF8Buffer {
			String(decoding: $0, as: UTF8.self)
		}
	}
}
