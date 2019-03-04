//
//  OptionSet+Sequence.swift
//  LogPuppy
//
//  Created by John Clayton on 3/4/19.
//  Copyright © 2019 ImpossibleFlight, LLC. All rights reserved.
//

import Foundation


// From: https://stackoverflow.com/questions/32102936/how-do-you-enumerate-optionsettype-in-swift

public struct OptionSetIterator<Element: OptionSet>: IteratorProtocol where Element.RawValue: FixedWidthInteger {
	private let value: Element

	public init(element: Element) {
		self.value = element
	}

	private lazy var remainingBits = value.rawValue
	private var bitMask: Element.RawValue = 1

	public mutating func next() -> Element? {
		while remainingBits != 0 {
			defer { bitMask = bitMask &* 2 }
			if remainingBits & bitMask != 0 {
				remainingBits = remainingBits & ~bitMask
				return Element(rawValue: bitMask)
			}
		}
		return nil
	}
}

extension OptionSet where Self.RawValue: FixedWidthInteger {
	public func makeIterator() -> OptionSetIterator<Self> {
		return OptionSetIterator(element: self)
	}
}
