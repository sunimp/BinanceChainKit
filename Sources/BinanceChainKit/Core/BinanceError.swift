//
//  BinanceError.swift
//  BinanceChainKit
//
//  Created by Sun on 2024/8/21.
//

import Foundation

import Alamofire

// MARK: - BinanceError

public class BinanceError: Error {
    public var code: Int
    public var message: String
    public var httpStatus: Int? = nil

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
