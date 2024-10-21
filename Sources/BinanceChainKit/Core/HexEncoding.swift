//
//  HexEncoding.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

import Foundation

import Alamofire

struct HexEncoding: ParameterEncoding {
    // MARK: Properties

    private let data: Data

    // MARK: Lifecycle

    init(data: Data) {
        self.data = data
    }

    // MARK: Functions

    func encode(_ urlRequest: URLRequestConvertible, with _: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data.hexdata
        return urlRequest
    }
}
