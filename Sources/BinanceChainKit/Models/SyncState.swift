//
//  SyncState.swift
//
//  Created by Sun on 2019/7/31.
//

import Foundation

import GRDB

class SyncState: Record {
    // MARK: Nested Types

    enum Columns: String, ColumnExpression {
        case primaryKey
        case transactionSyncedUntilTime
    }

    // MARK: Overridden Properties

    override class var databaseTableName: String {
        "sync_states"
    }

    // MARK: Properties

    let transactionSyncedUntilTime: Date

    private let primaryKey = "sync_state"

    // MARK: Lifecycle

    init(transactionSyncedUntilTime: TimeInterval) {
        self.transactionSyncedUntilTime = Date(timeIntervalSince1970: transactionSyncedUntilTime)
        
        super.init()
    }
    
    required init(row: Row) throws {
        transactionSyncedUntilTime = row[Columns.transactionSyncedUntilTime]
        
        try super.init(row: row)
    }

    // MARK: Overridden Functions

    override func encode(to container: inout PersistenceContainer) throws {
        container[Columns.primaryKey] = primaryKey
        container[Columns.transactionSyncedUntilTime] = transactionSyncedUntilTime
    }
}
