//
//  BinanceAddressValidator.swift
//  BinanceChainKit
//
//  Created by Sun on 2023/2/28.
//

import Foundation

public class BinanceAddressValidator {
    // MARK: Properties

    private let segWitBech32: SegWitBech32

    // MARK: Lifecycle

    public init(prefix: String) {
        segWitBech32 = SegWitBech32(hrp: prefix)
    }

    // MARK: Functions

    public func validate(address: String) throws {
        try _ = segWitBech32.decode(addr: address)
    }
}
