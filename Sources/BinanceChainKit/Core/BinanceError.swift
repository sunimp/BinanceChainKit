//
//  BinanceError.swift
//  BinanceChainKit
//
//  Created by Sun on 2020/5/7.
//

import Foundation

import Alamofire

// MARK: - BinanceError

public class BinanceError: Error {
    // MARK: Properties

    public var code: Int
    public var message: String
    public var httpStatus: Int? = nil

    // MARK: Lifecycle

    required init(code: Int, message: String, httpStatus: Int?) {
        self.code = code
        self.message = message
        self.httpStatus = httpStatus
    }
}

// MARK: CustomStringConvertible

extension BinanceError: CustomStringConvertible {
    public var description: String {
        "(\(code)) \(message)"
    }
}
