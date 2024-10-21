//
//  Messages.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

import Foundation

import SwiftProtobuf

// MARK: - Message

class Message {
    // MARK: Nested Types

    private enum MessageType: String {
        case newOrder = "CE6DC043"
        case cancelOrder = "166E681B"
        case freeze = "E774B32D"
        case unfreeze = "6515FF0D"
        case transfer = "2A2C87FA"
        case transferOut = "800819C0"
        case vote = "A1CADD36"
        case stdtx = "F0625DEE"
        case signature = ""
        case publicKey = "EB5AE987"
    }

    private enum Source: Int {
        case hidden = 0
        case broadcast = 1
    }

    // MARK: Properties

    private var type: MessageType = .newOrder
    private var wallet: Wallet
    private var symbol = ""
    private var orderID = ""
    private var orderType: OrderType = .limit
    private var side: Side = .buy
    private var price: Double = 0
    private var amount: Double = 0
    private var quantity: Double = 0
    private var timeInForce: TimeInForce = .goodTillExpire
    private var data = Data()
    private var memo = ""
    private var toAddress = ""
    private var bscPublicKeyHash = Data()
    private var expireTime: Int64 = 0
    private var proposalID = 0
    private var voteOption: VoteOption = .no
    private var source: Source = .broadcast

    // MARK: Lifecycle

    // MARK: - Constructors

    private init(type: MessageType, wallet: Wallet) {
        self.type = type
        self.wallet = wallet
    }

    // MARK: Static Functions

    static func newOrder(
        symbol: String,
        orderType: OrderType,
        side: Side,
        price: Double,
        quantity: Double,
        timeInForce: TimeInForce,
        wallet: Wallet
    )
        -> Message {
        let message = Message(type: .newOrder, wallet: wallet)
        message.symbol = symbol
        message.orderType = orderType
        message.side = side
        message.price = price
        message.quantity = quantity
        message.timeInForce = timeInForce
        message.orderID = wallet.nextAvailableOrderID()
        return message
    }

    static func cancelOrder(symbol: String, orderID: String, wallet: Wallet) -> Message {
        let message = Message(type: .cancelOrder, wallet: wallet)
        message.symbol = symbol
        message.orderID = orderID
        return message
    }

    static func freeze(symbol: String, amount: Double, wallet: Wallet) -> Message {
        let message = Message(type: .freeze, wallet: wallet)
        message.symbol = symbol
        message.amount = amount
        return message
    }

    static func unfreeze(symbol: String, amount: Double, wallet: Wallet) -> Message {
        let message = Message(type: .unfreeze, wallet: wallet)
        message.symbol = symbol
        message.amount = amount
        return message
    }

    static func transfer(
        symbol: String,
        amount: Double,
        to address: String,
        memo: String = "",
        wallet: Wallet
    )
        -> Message {
        let message = Message(type: .transfer, wallet: wallet)
        message.symbol = symbol
        message.amount = amount
        message.toAddress = address
        message.memo = memo
        return message
    }

    static func transferOut(
        symbol: String,
        bscPublicKeyHash: Data,
        amount: Double,
        expireTime: Int64,
        wallet: Wallet
    )
        -> Message {
        let message = Message(type: .transferOut, wallet: wallet)
        message.symbol = symbol
        message.amount = amount
        message.bscPublicKeyHash = bscPublicKeyHash
        message.expireTime = expireTime
        return message
    }

    static func vote(proposalID: Int, vote option: VoteOption, wallet: Wallet) -> Message {
        let message = Message(type: .vote, wallet: wallet)
        message.proposalID = proposalID
        message.voteOption = option
        return message
    }

    // MARK: Functions

    // MARK: - Public

    func encode() throws -> Data {
        // Generate encoded message
        var message = Data()
        message.append(type.rawValue.unhexlify)
        try message.append(body(for: type))

        // Generate signature
        let signature = try body(for: .signature)

        // Wrap in StdTx structure
        var stdtx = StdTx()
        stdtx.msgs.append(message)
        stdtx.signatures.append(signature)
        stdtx.memo = memo
        stdtx.source = Int64(Source.broadcast.rawValue)
        stdtx.data = data

        // Prefix length and stdtx type
        var content = Data()
        content.append(MessageType.stdtx.rawValue.unhexlify)
        try content.append(stdtx.serializedData())

        // Complete Standard Transaction
        var transaction = Data()
        transaction.append(content.count.varint)
        transaction.append(content)

        // Prepare for next transaction
        wallet.incrementSequence()

        return transaction
    }

    // MARK: - Private

    private func body(for type: MessageType) throws -> Data {
        switch type {
        case .newOrder:
            var pb = NewOrder()
            pb.sender = wallet.publicKeyHashHex.unhexlify
            pb.id = orderID
            pb.symbol = symbol
            pb.timeinforce = Int64(timeInForce.rawValue)
            pb.ordertype = Int64(orderType.rawValue)
            pb.side = Int64(side.rawValue)
            pb.price = Int64(price.encoded)
            pb.quantity = Int64(quantity.encoded)
            return try pb.serializedData()

        case .cancelOrder:
            var pb = CancelOrder()
            pb.symbol = symbol
            pb.sender = wallet.publicKeyHashHex.unhexlify
            pb.refid = orderID
            return try pb.serializedData()

        case .freeze:
            var pb = TokenFreeze()
            pb.symbol = symbol
            pb.from = wallet.publicKeyHashHex.unhexlify
            pb.amount = Int64(amount.encoded)
            return try pb.serializedData()

        case .unfreeze:
            var pb = TokenUnfreeze()
            pb.symbol = symbol
            pb.from = wallet.publicKeyHashHex.unhexlify
            pb.amount = Int64(amount.encoded)
            return try pb.serializedData()

        case .transfer:
            var token = Send.Token()
            token.denom = symbol
            token.amount = Int64(amount.encoded)

            var input = Send.Input()
            input.address = wallet.publicKeyHashHex.unhexlify
            input.coins = [token]

            var output = Send.Output()
            output.address = try wallet.publicKeyHash(fromAddress: toAddress)
            output.coins = [token]

            var send = Send()
            send.inputs.append(input)
            send.outputs.append(output)

            return try send.serializedData()

        case .transferOut:
            var token = Send.Token()
            token.denom = symbol
            token.amount = Int64(amount.encoded)

            var transferOut = TransferOut()
            transferOut.from = wallet.publicKeyHashHex.unhexlify
            transferOut.to = bscPublicKeyHash
            transferOut.amount = token
            transferOut.expireTime = expireTime

            return try transferOut.serializedData()

        case .signature:
            var pb = StdSignature()
            pb.sequence = Int64(wallet.sequence)
            pb.accountNumber = Int64(wallet.accountNumber)
            pb.pubKey = try body(for: .publicKey)
            pb.signature = try signature()
            return try pb.serializedData()

        case .publicKey:
            let key = wallet.publicKey
            var data = Data()
            data.append(type.rawValue.unhexlify)
            data.append(key.count.varint)
            data.append(key)
            return data

        case .vote:
            var vote = Vote()
            vote.proposalID = Int64(proposalID)
            vote.voter = wallet.publicKeyHashHex.unhexlify
            vote.option = Int64(voteOption.rawValue)
            return try vote.serializedData()

        default:
            throw BinanceError(code: 0, message: "Invalid type", httpStatus: nil)
        }
    }

    private func signature() throws -> Data {
        let json = json(for: .signature)
        let data = Data(json.utf8)
        return try wallet.sign(message: data)
    }

    private func json(for type: MessageType) -> String {
        switch type {
        case .newOrder:
            String(
                format: JSON.newOrder,
                orderID,
                orderType.rawValue,
                price.encoded,
                quantity.encoded,
                wallet.address,
                side.rawValue,
                symbol,
                timeInForce.rawValue
            )

        case .cancelOrder:
            String(
                format: JSON.cancelOrder,
                orderID,
                wallet.address,
                symbol
            )

        case .freeze:
            String(
                format: JSON.freeze,
                amount.encoded,
                wallet.address,
                symbol
            )

        case .unfreeze:
            String(
                format: JSON.unfreeze,
                amount.encoded,
                wallet.address,
                symbol
            )

        case .transfer:
            String(
                format: JSON.transfer,
                wallet.address,
                amount.encoded,
                symbol,
                toAddress,
                amount.encoded,
                symbol
            )

        case .transferOut:
            String(
                format: JSON.transferOut,
                amount.encoded,
                symbol,
                expireTime,
                wallet.address,
                EIP55.format(address: bscPublicKeyHash)
            )

        case .vote:
            String(
                format: JSON.vote,
                voteOption.rawValue,
                proposalID,
                wallet.address
            )

        case .signature:
            String(
                format: JSON.signature,
                wallet.accountNumber,
                wallet.chainID,
                memo,
                json(for: self.type),
                wallet.sequence,
                source.rawValue
            )

        default:
            "{}"
        }
    }
}

extension Double {
    fileprivate var encoded: Int {
        // Multiply by 1e8 (10^8) and round to int
        Int(self * pow(10, 8))
    }
}

// MARK: - JSON

private class JSON {
    // Signing requires a strictly ordered JSON string. Neither swift nor
    // SwiftyJSON maintained the order, so instead we use strings.

    static let signature = """
        {"account_number":"%d","chain_id":"%@","data":null,"memo":"%@","msgs":[%@],"sequence":"%d","source":"%d"}
        """

    static let newOrder = """
        {"id":"%@","ordertype":%d,"price":%d,"quantity":%d,"sender":"%@","side":%d,"symbol":"%@","timeinforce":%d}
        """

    static let cancelOrder = """
        {"refid":"%@","sender":"%@","symbol":"%@"}
        """

    static let freeze = """
        {"amount":%ld,"from":"%@","symbol":"%@"}
        """

    static let unfreeze = """
        {"amount":%ld,"from":"%@","symbol":"%@"}
        """

    static let transfer = """
        {"inputs":[{"address":"%@","coins":[{"amount":%ld,"denom":"%@"}]}],"outputs":[{"address":"%@","coins":[{"amount":%ld,"denom":"%@"}]}]}
        """

    static let transferOut = """
        {"amount":{"amount":%ld,"denom":"%@"},"expire_time":%d,"from":"%@","to":"%@"}
        """

    static let vote = """
        {"option":%d,proposal_id":%d,voter":"%@"}
        """
}
