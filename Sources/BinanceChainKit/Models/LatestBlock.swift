//
//  LatestBlock.swift
//  BinanceChainKit
//
//  Created by Sun on 2024/8/21.
//

import Foundation

import GRDB

// MARK: - LatestBlock

class LatestBlock: Record {
    private let primaryKey = "primary_key"
    let height: Int
    let hash: String
    let time: Date
    
    init(height: Int, hash: String, time: Date) {
        self.height = height
        self.hash = hash
        self.time = time
        
        super.init()
    }
    
    override class var databaseTableName: String {
        "latest_block"
    }
    
    enum Columns: String, ColumnExpression {
        case primaryKey
        case height
        case hash
        case time
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
