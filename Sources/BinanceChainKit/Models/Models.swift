//
//  Models.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

import Foundation

// MARK: - Times

class Times: CustomStringConvertible {
    var apTime = Date()
    var blockTime = Date()
}

// MARK: - Validators

class Validators: CustomStringConvertible {
    var blockHeight = 0
    var validators: [Validator] = []
}

// MARK: - Validator

class Validator: CustomStringConvertible {
    var address = ""
    var publicKey = Data()
    var votingPower = 0
}

// MARK: - Peer

class Peer: CustomStringConvertible {
    var id = ""
    var originalListenAddr = ""
    var listenAddr = ""
    var accessAddr = ""
    var streamAddr = ""
    var network = ""
    var version = ""
    var moniker = ""
    var capabilities: [String] = []
    var accelerated = false
}

// MARK: - NodeInfo

class NodeInfo: CustomStringConvertible {
    var id = ""
    var listenAddr = ""
    var network = ""
    var version = ""
    var moniker = ""
    var address = ""
    var channels = ""
    var other: [String: String] = [:]
    var syncInfo: [String: Any] = [:]
    var validatorInfo = Validator()
}

// MARK: - Transactions

class Transactions: CustomStringConvertible {
    var total = 0
    var tx: [Tx] = []
}

// MARK: - ApiTransaction

class ApiTransaction: CustomStringConvertible {
    var hash = ""
    var log = ""
    var data = ""
    var height = ""
    var code = 0
    var ok = false
    var tx = Tx()
}

// MARK: - Account

public class Account: CustomStringConvertible {
    public var accountNumber = 0
    public var address = ""
    public var balances: [ApiBalance] = []
    public var publicKey = Data()
    public var sequence = 0
}

// MARK: - AccountSequence

class AccountSequence: CustomStringConvertible {
    var sequence = 0
}

// MARK: - ApiBalance

public class ApiBalance: CustomStringConvertible {
    public var symbol = ""
    public var free: Decimal = 0
    public var locked: Decimal = 0
    public var frozen: Decimal = 0
}

// MARK: - Token

class Token: CustomStringConvertible {
    var name = ""
    var symbol = ""
    var originalSymbol = ""
    var totalSupply: Double = 0
    var owner = ""
}

// MARK: - Market

class Market: CustomStringConvertible {
    var baseAssetSymbol = ""
    var quoteAssetSymbol = ""
    var price: Double = 0
    var tickSize: Double = 0
    var lotSize: Double = 0
}

// MARK: - Fee

class Fee: CustomStringConvertible {
    var msgType = ""
    var fee = ""
    var feeFor: FeeFor = .all
    var multiTransferFee = 0
    var lowerLimitAsMulti = 0
    var fixedFeeParams: FixedFeeParams?
}

// MARK: - FixedFeeParams

class FixedFeeParams: CustomStringConvertible {
    var msgType = ""
    var fee = ""
    var feeFor: FeeFor = .all
}

// MARK: - PriceQuantity

class PriceQuantity: CustomStringConvertible {
    var price: Double = 0
    var quantity: Double = 0
}

// MARK: - MarketDepth

class MarketDepth: CustomStringConvertible {
    var asks: [PriceQuantity] = []
    var bids: [PriceQuantity] = []
}

// MARK: - MarketDepthUpdate

class MarketDepthUpdate: CustomStringConvertible {
    var symbol = ""
    var depth = MarketDepth()
}

// MARK: - BlockTradePage

class BlockTradePage: CustomStringConvertible {
    var total = 0
    var blockTrade: [BlockTrade] = []
}

// MARK: - BlockTrade

class BlockTrade: CustomStringConvertible {
    var blockTime: TimeInterval = 0
    var fee = 0
    var height = 0
    var trade: [Trade] = []
}

// MARK: - Candlestick

class Candlestick: CustomStringConvertible {
    var close: Double = 0
    var closeTime = Date()
    var high: Double = 0
    var low: Double = 0
    var numberOfTrades = 0
    var open: Double = 0
    var openTime = Date()
    var quoteAssetVolume: Double = 0
    var volume: Double = 0
    var closed = false
}

// MARK: - OrderList

class OrderList: CustomStringConvertible {
    var total = 0
    var orders: [Order] = []
}

// MARK: - Order

class Order: CustomStringConvertible {
    var cumulateQuantity = ""
    var fee = ""
    var lastExecutedPrice = ""
    var lastExecuteQuantity = ""
    var orderCreateTime = Date()
    var orderID = ""
    var owner = ""
    var price: Double = 0
    var side: Side = .buy
    var status: Status = .acknowledge
    var symbol = ""
    var timeInForce: TimeInForce = .immediateOrCancel
    var tradeID = ""
    var transactionHash = ""
    var transactionTime = Date()
    var type: OrderType = .limit
}

// MARK: - TickerStatistics

class TickerStatistics: CustomStringConvertible {
    var askPrice: Double = 0
    var askQuantity: Double = 0
    var bidPrice: Double = 0
    var bidQuantity: Double = 0
    var closeTime = Date()
    var count = 0
    var firstID = ""
    var highPrice: Double = 0
    var lastID = ""
    var lastPrice: Double = 0
    var lastQuantity: Double = 0
    var lowPrice: Double = 0
    var openPrice: Double = 0
    var openTime = Date()
    var prevClosePrice: Double = 0
    var priceChange: Double = 0
    var priceChangePercent: Double = 0
    var quoteVolume: Double = 0
    var symbol = ""
    var volume: Double = 0
    var weightedAvgPrice: Double = 0
}

// MARK: - TradePage

class TradePage: CustomStringConvertible {
    var total = 0
    var trade: [Trade] = []
}

// MARK: - Trade

class Trade: CustomStringConvertible {
    var baseAsset = ""
    var blockHeight = 0
    var buyFee = ""
    var buyerID = ""
    var buyerOrderID = ""
    var price = ""
    var quantity = ""
    var quoteAsset = ""
    var sellFee = ""
    var sellerID = ""
    var symbol = ""
    var time = Date()
    var tradeID = ""
}

// MARK: - TxPage

class TxPage: CustomStringConvertible {
    var total = 0
    var tx: [Tx] = []
}

// MARK: - Tx

class Tx: CustomStringConvertible {
    var blockHeight: Double = 0
    var code = 0
    var confirmBlocks: Double = 0
    var data = ""
    var fromAddr = ""
    var orderID = ""
    var timestamp = Date()
    var toAddr = ""
    var txAge: Double = 0
    var txAsset = ""
    var txFee = ""
    var txHash = ""
    var txType: TxType = .newOrder
    var value = ""
    var memo = ""
}

// MARK: - Transfer

class Transfer: CustomStringConvertible {
    var height = 0
    var transactionHash = ""
    var fromAddr = ""
    var transferred: [Transferred] = []
}

// MARK: - Transferred

class Transferred: CustomStringConvertible {
    var toAddr = ""
    var amounts: [Amount] = []
}

// MARK: - Amount

class Amount: CustomStringConvertible {
    var asset = ""
    var amount: Double = 0
}
