//
//  Balance.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/30.
//

import Foundation

import GRDB

// MARK: - Balance

class Balance: Record {
    // MARK: Nested Types

    enum Columns: String, ColumnExpression {
        case amount
        case symbol
    }

    // MARK: Overridden Properties

    override class var databaseTableName: String {
        "balances"
    }

    // MARK: Properties

    let symbol: String
    var amount: Decimal

    // MARK: Lifecycle

    init(symbol: String, amount: Decimal) {
        self.symbol = symbol
        self.amount = amount

        super.init()
    }

    required init(row: Row) throws {
        symbol = row[Columns.symbol]
        amount = row[Columns.amount]

        try super.init(row: row)
    }

    // MARK: Overridden Functions

    override func encode(to container: inout PersistenceContainer) throws {
        container[Columns.symbol] = symbol
        container[Columns.amount] = amount
    }
}

// MARK: CustomStringConvertible

extension Balance: CustomStringConvertible {
    public var description: String {
        "BALANCE: [symbol: \(symbol); amount: \(amount)]"
    }
}
