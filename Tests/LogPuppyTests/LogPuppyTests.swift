//
//  LogPuppyTests.swift
//  LogPuppyTests
//
//  Created by John Clayton on 3/3/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import XCTest
@testable import LogPuppy

class LogPuppyTests: XCTestCase {

	var system = "com.impossibleflight.LogPuppy"
	var category = "TEST"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testLogsAllLevels() {
		var output = ""
		let destination = OutputStreamDestination(system: system, category: category, levels: .all, outputStream: &output)
		let logger = Logger(destinations: [destination])

		logger.log(.default, format: "something at .default")

		let defaultRange: NSRange = (output as NSString).range(of: ".default")
		XCTAssertTrue(defaultRange.location != NSNotFound)
	}

	func testOSLog() {
		let destination = OSLogDestination(system: system, category: category, levels: .all)
		let logger = Logger(destinations: [destination])
		logger.log(.default, format: "something at .default")
		
	}

}
