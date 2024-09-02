//
//  LatestBlock.swift
//
//  Created by Sun on 2019/7/30.
//

import Foundation

import GRDB

// MARK: - LatestBlock

class LatestBlock: Record {
    // MARK: Nested Types

    enum Columns: String, ColumnExpression {
        case primaryKey
        case height
        case hash
        case time
    }

    // MARK: Overridden Properties

    override class var databaseTableName: String {
        "latest_block"
    }

    // MARK: Properties

    let height: Int
    let hash: String
    let time: Date

    private let primaryKey = "primary_key"

    // MARK: Lifecycle

    init(height: Int, hash: String, time: Date) {
        self.height = height
        self.hash = hash
        self.time = time
        
        super.init()
    }
    
    required init(row: Row) throws {
        height = row[Columns.height]
        hash = row[Columns.hash]
        time = row[Columns.time]
        
        try super.init(row: row)
    }
    
    init?(syncInfo: [String: Any]) {
        guard
            let latestBlockHeightValue = syncInfo["latest_block_height"],
            let latestBlockHeight = latestBlockHeightValue as? NSNumber
        else {
            return nil
        }
        
        guard
            let latestBlockHashValue = syncInfo["latest_block_hash"],
            let latestBlockHash = latestBlockHashValue as? String
        else {
            return nil
        }
        
        guard
            let latestBlockTimeValue = syncInfo["latest_block_time"],
            let latestBlockTimeStr = latestBlockTimeValue as? String,
            let latestBlockTime = latestBlockTimeStr.toDate()
        else {
            return nil
        }
        
        height = Int(truncating: latestBlockHeight)
        hash = latestBlockHash
        time = latestBlockTime
        
        super.init()
    }

    // MARK: Overridden Functions

    override func encode(to container: inout PersistenceContainer) throws {
        container[Columns.primaryKey] = primaryKey
        container[Columns.height] = height
        container[Columns.hash] = hash
        container[Columns.time] = time
    }
}

// MARK: CustomStringConvertible

extension LatestBlock: CustomStringConvertible {
    public var description: String {
        "LATEST BLOCK: [height: \(height), hash: \(hash); time: \(time)]"
    }
}
