//
//  Functions.swift
//  LogPuppy
//
//  Created by John Clayton on 3/7/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation


/// Calls `assert(::file:line:)` which stops execution when the condition is false in builds where it fires. In builds with optimization settings that disable asserts, logs the supplied message if the condition is false.
///
/// - SeeAlso: assert(::file:line:)
public func assertOrLog(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, logger: Logger = Logger.errorLogger(), file: String = #file, line: Int = #line) {
	assert(condition, message)
	if !condition() {
		logger.error(message(), file: file, line: line)
	}
}

/// Calls `assertionFailure(:file:line:)` which will stop execution in builds where it fires. In builds with optimization settings that disable asserts, logs the supplied message.
///
/// - SeeAlso: assertionFailure(:file:line:)
public func assertionFailureOrLog(_ message: @autoclosure () -> String, logger: Logger = Logger.errorLogger(), file: String = #file, line: Int = #line) {
	assertionFailure(message)
	logger.error(message(), file: file, line: line)
}

