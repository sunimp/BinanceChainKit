//
//  Wallet.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

import Foundation

import HDWalletKit
import SWCryptoKit

// MARK: - Wallet

class Wallet {
    // MARK: Static Properties

    static let bcPrivateKeyPath = "m/44'/714'/0'/0/0"
    static let bscMainNetKeyPath = "m/44'/60'/0'/0/0"
    static let bscTestNetKeyPath = "m/44'/1'/0'/0/0"

    // MARK: Properties

    var sequence = 0
    var accountNumber = 0
    var chainID = ""

    let publicKey: Data
    let address: String

    private let hdWallet: HDWallet
    private let publicKeyHash: Data
    private let segWitHelper: SegWitBech32

    // MARK: Computed Properties

    var publicKeyHashHex: String {
        publicKeyHash.hexlify
    }

    // MARK: Lifecycle

    init(hdWallet: HDWallet, segWitHelper: SegWitBech32) throws {
        self.segWitHelper = segWitHelper
        self.hdWallet = hdWallet

        let privateKey = try hdWallet.privateKey(path: Wallet.bcPrivateKeyPath).raw
        publicKey = Crypto.publicKey(privateKey: privateKey, compressed: true)
        publicKeyHash = Crypto.ripeMd160Sha256(publicKey)
        address = try segWitHelper.encode(program: publicKeyHash)
    }

    // MARK: Functions

    func publicKeyHash(path: String) throws -> Data {
        let privateKey = try hdWallet.privateKey(path: path).raw
        let publicKey = Data(Crypto.publicKey(privateKey: privateKey, compressed: false).dropFirst())
        let sha3Hash = Crypto.sha3(publicKey)

        return Data(sha3Hash.suffix(20))
    }

    func incrementSequence() {
        sequence += 1
    }

    func nextAvailableOrderID() -> String {
        String(format: "%@-%d", publicKeyHashHex.uppercased(), sequence + 1)
    }

    func publicKeyHash(fromAddress address: String) throws -> Data {
        try segWitHelper.decode(addr: address)
    }

    func sign(message: Data) throws -> Data {
        let hash = Crypto.sha256(message)
        return try Crypto.sign(
            data: hash,
            privateKey: hdWallet.privateKey(path: Wallet.bcPrivateKeyPath).raw,
            compact: true
        )
    }
}

// MARK: CustomStringConvertible

extension Wallet: CustomStringConvertible {
    var description: String {
        String(
            format: "Wallet [address=%@ accountNumber=%d, sequence=%d, chain_id=%@, account=%@, publicKey=%@]",
            address,
            accountNumber,
            sequence,
            chainID,
            address,
            publicKey.hexlify
        )
    }
}
