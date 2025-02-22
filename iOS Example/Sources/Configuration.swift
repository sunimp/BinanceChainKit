//
//  Configuration.swift
//  BinanceChainKit-Example
//
//  Created by Sun on 2024/8/21.
//

import Foundation

import BinanceChainKit
import SWToolKit

class Configuration {
    static let shared = Configuration()

    let networkType: BinanceChainKit.NetworkType = .mainNet
    let minLogLevel: Logger.Level = .error

    let defaultWords = "error sound chuckle illness reveal echo close lock buddy large cook apple saddle rural trouble matter pluck inner window need sphere census smooth sun"
}
