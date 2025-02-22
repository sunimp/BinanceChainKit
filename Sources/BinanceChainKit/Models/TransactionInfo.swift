//
//  TransactionInfo.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

import Foundation

public class TransactionInfo {
    // MARK: Properties

    public let hash: String
    public let blockHeight: Int
    public let date: Date
    public let from: String
    public let to: String
    public let amount: Decimal
    public let fee: Decimal
    public let symbol: String
    public let memo: String?

    // MARK: Lifecycle

    init(transaction: Transaction) {
        hash = transaction.hash
        blockHeight = transaction.blockHeight
        date = transaction.date
        from = transaction.from
        to = transaction.to
        amount = transaction.amount
        fee = transaction.fee
        symbol = transaction.symbol
        memo = transaction.memo
    }
}
