//
//  BinanceChainKit.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

import Combine
import Foundation

import HDWalletKit
import SWExtensions
import SWToolKit

// MARK: - BinanceChainKit

public class BinanceChainKit {
    // MARK: Properties

    public let networkType: NetworkType
    @DistinctPublished
    public var syncState: SyncState = .notSynced(error: BinanceChainKit.SyncError.notStarted)
    @DistinctPublished
    public var lastBlockHeight: Int?

    private var cancellables = Set<AnyCancellable>()
    private var tasks = Set<AnyTask>()

    private let balanceManager: BalanceManager
    private let transactionManager: TransactionManager
    private let reachabilityManager: ReachabilityManager
    private let segWitHelper: SegWitBech32
    private let logger: Logger?

    private let wallet: Wallet
    private let lastBlockHeightSubject = PassthroughSubject<Int, Never>()
    private let syncStateSubject = PassthroughSubject<SyncState, Never>()

    private var assets = [Asset]()

    // MARK: Computed Properties

    public var binanceBalance: Decimal {
        balanceManager.balance(symbol: "BNB")?.amount ?? 0
    }

    public var account: String {
        wallet.address
    }

    // MARK: Lifecycle

    init(
        wallet: Wallet,
        balanceManager: BalanceManager,
        transactionManager: TransactionManager,
        reachabilityManager: ReachabilityManager,
        segWitHelper: SegWitBech32,
        networkType: NetworkType,
        logger: Logger? = nil
    ) {
        self.wallet = wallet
        self.balanceManager = balanceManager
        self.transactionManager = transactionManager
        self.reachabilityManager = reachabilityManager
        self.segWitHelper = segWitHelper
        self.networkType = networkType
        self.logger = logger

        lastBlockHeight = balanceManager.latestBlock?.height

        reachabilityManager.$isReachable
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    // MARK: Functions

    private func asset(symbol: String) -> Asset? {
        assets.first { $0.symbol == symbol }
    }

    private func _watchOnChain(transaction hash: String) async {
        do {
            _ = try await transactionManager.blockHeight(forTransaction: hash)
            refresh()
        } catch {
            logger?.error("Transaction send error: \(error)")
        }
    }

    private func watchOnChain(transaction hash: String) {
        Task { [weak self] in await self?._watchOnChain(transaction: hash) }.store(in: &tasks)
    }

    private func syncBalance(account: String) {
        Task { [weak self] in await self?.balanceManager.sync(account: account) }.store(in: &tasks)
    }

    private func syncTransactions() {
        Task { [weak self] in await self?.transactionManager.sync() }.store(in: &tasks)
    }
}

// Public API Extension

extension BinanceChainKit {
    public func register(symbol: String) -> Asset {
        let balance = balanceManager.balance(symbol: symbol)?.amount ?? 0
        let asset = Asset(symbol: symbol, balance: balance, address: wallet.address)

        assets.append(asset)

        return asset
    }

    public func unregister(asset: Asset) {
        assets.removeAll { $0 == asset }
    }

    public func refresh() {
        guard reachabilityManager.isReachable else {
            syncState = .notSynced(error: ReachabilityManager.ReachabilityError.notReachable)
            return
        }

        guard syncState != .syncing else {
            logger?.debug("Already syncing balances")
            return
        }

        logger?.debug("Syncing")
        syncState = .syncing

        syncBalance(account: wallet.address)
        syncTransactions()
    }

    public func validate(address: String) throws {
        try _ = segWitHelper.decode(addr: address)
    }

    public func transactions(
        symbol: String,
        filterType: TransactionFilterType? = nil,
        fromTransactionHash: String? = nil,
        limit: Int? = nil
    )
        -> [TransactionInfo] {
        transactionManager.transactions(
            symbol: symbol,
            filterType: filterType,
            fromTransactionHash: fromTransactionHash,
            limit: limit
        )
        .map { transaction in
            TransactionInfo(transaction: transaction)
        }
    }

    public func transaction(symbol: String, hash: String) -> TransactionInfo? {
        transactionManager.transaction(symbol: symbol, hash: hash).map { TransactionInfo(transaction: $0) }
    }

    public func send(symbol: String, to: String, amount: Decimal, memo: String) async throws -> String {
        logger?.debug("Sending \(amount) \(symbol) to \(to)")

        let hash = try await transactionManager.send(symbol: symbol, to: to, amount: amount, memo: memo)
        watchOnChain(transaction: hash)
        return hash
    }

    public func moveToBSC(symbol: String, amount: Decimal) async throws -> String {
        logger?.debug("Moving \(amount) \(symbol) to BSC")

        let bscPublicKeyHash = try wallet.publicKeyHash(
            path: networkType == .mainNet
                ? Wallet.bscMainNetKeyPath
                : Wallet.bscTestNetKeyPath
        )

        let hash = try await transactionManager.moveToBsc(
            symbol: symbol,
            bscPublicKeyHash: bscPublicKeyHash,
            amount: amount
        )
        watchOnChain(transaction: hash)
        return hash
    }

    public var statusInfo: [(String, Any)] {
        [
            ("Synced Until", balanceManager.latestBlock?.time ?? "N/A"),
            ("Last Block Height", balanceManager.latestBlock?.height ?? "N/A"),
            ("Sync State", syncState.description),
            ("RPC Host", networkType.endpoint),
        ]
    }
}

// MARK: IBalanceManagerDelegate

extension BinanceChainKit: IBalanceManagerDelegate {
    func didSync(balances: [Balance], latestBlockHeight: Int) {
        for balance in balances {
            asset(symbol: balance.symbol)?.balance = balance.amount
        }
        lastBlockHeight = latestBlockHeight
        syncState = .synced
    }

    func didFailToSync(error: Error) {
        syncState = .notSynced(error: error)
    }
}

// MARK: ITransactionManagerDelegate

extension BinanceChainKit: ITransactionManagerDelegate {
    func didSync(transactions: [Transaction]) {
        let transactionsMap = Dictionary(grouping: transactions, by: { $0.symbol })

        for (symbol, transactions) in transactionsMap {
            asset(symbol: symbol)?.transactionsSubject.send(transactions.map { TransactionInfo(transaction: $0) })
        }
    }
}

extension BinanceChainKit {
    public static func instance(
        seed: Data,
        networkType: NetworkType = .mainNet,
        walletID: String,
        minLogLevel: Logger.Level = .error
    ) throws
        -> BinanceChainKit {
        let logger = Logger(minLogLevel: minLogLevel)

        let uniqueID = "\(walletID)-\(networkType)"
        let storage: IStorage = try Storage(
            databaseDirectoryURL: dataDirectoryURL(),
            databaseFileName: "binance-chain-\(uniqueID)"
        )

        let segWitHelper = Self.segWitHelper(networkType: networkType)
        let wallet = try Self.wallet(seed: seed, segWitHelper: segWitHelper)

        let apiProvider = BinanceChainApiProvider(
            networkManager: NetworkManager(logger: logger),
            endpoint: networkType.endpoint
        )

        let accountSyncer = AccountSyncer(apiProvider: apiProvider, logger: logger)
        let balanceManager = BalanceManager(storage: storage, accountSyncer: accountSyncer, logger: logger)
        let transactionManager = TransactionManager(
            storage: storage,
            wallet: wallet,
            apiProvider: apiProvider,
            accountSyncer: accountSyncer,
            logger: logger
        )
        let reachabilityManager = ReachabilityManager()

        let binanceChainKit = BinanceChainKit(
            wallet: wallet,
            balanceManager: balanceManager,
            transactionManager: transactionManager,
            reachabilityManager: reachabilityManager,
            segWitHelper: segWitHelper,
            networkType: networkType,
            logger: logger
        )
        balanceManager.delegate = binanceChainKit
        transactionManager.delegate = binanceChainKit

        return binanceChainKit
    }

    public static func clear(exceptFor excludedFiles: [String]) throws {
        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(at: dataDirectoryURL(), includingPropertiesForKeys: nil)

        for filename in fileURLs {
            if !excludedFiles.contains(where: { filename.lastPathComponent.contains($0) }) {
                try fileManager.removeItem(at: filename)
            }
        }
    }

    private static func dataDirectoryURL() throws -> URL {
        let fileManager = FileManager.default

        let url = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("binance-chain-kit", isDirectory: true)

        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        return url
    }

    private static func segWitHelper(networkType: NetworkType) -> SegWitBech32 {
        SegWitBech32(hrp: networkType.addressPrefix)
    }

    private static func wallet(seed: Data, segWitHelper: SegWitBech32) throws -> Wallet {
        let hdWallet = HDWallet(seed: seed, coinType: 714, xPrivKey: HDExtendedKeyVersion.xprv.rawValue)
        return try Wallet(hdWallet: hdWallet, segWitHelper: segWitHelper)
    }
}

extension BinanceChainKit {
    public enum SyncState: Equatable, CustomStringConvertible {
        case synced
        case syncing
        case notSynced(error: Error)

        // MARK: Computed Properties

        public var description: String {
            switch self {
            case .synced: "synced"
            case .syncing: "syncing"
            case let .notSynced(error): "not synced: \(error)"
            }
        }

        // MARK: Static Functions

        public static func == (lhs: SyncState, rhs: SyncState) -> Bool {
            switch (lhs, rhs) {
            case (.synced, .synced): true
            case (.syncing, .syncing): true
            case let (.notSynced(lhsError), .notSynced(rhsError)): "\(lhsError)" == "\(rhsError)"
            default: false
            }
        }
    }

    public enum NetworkType {
        case mainNet
        case testNet

        // MARK: Computed Properties

        public var addressPrefix: String {
            switch self {
            case .mainNet: "bnb"
            case .testNet: "tbnb"
            }
        }

        var endpoint: String {
            switch self {
            case .mainNet: "https://dex.binance.org"
            case .testNet: "https://testnet-dex.binance.org"
            }
        }
    }

    public enum ApiError: Error {
        case noTransactionReturned
        case wrongTransaction
    }

    public enum SyncError: Error {
        case notStarted
    }

    public enum CoderError: Error {
        case bitsConversionFailed
        case hrpMismatch(String, String)
        case checksumSizeTooLow
        case dataSizeMismatch(Int)
        case encodingCheckFailed
    }
}

extension BinanceChainKit {
    public static func firstAddress(seed: Data, networkType: NetworkType) throws -> String {
        let helper = segWitHelper(networkType: networkType)
        let wallet = try wallet(seed: seed, segWitHelper: helper)
        
        return wallet.address
    }
}
