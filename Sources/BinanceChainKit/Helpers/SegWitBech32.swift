//
//  SegWitBech32.swift
//  BinanceChainKit
//
//  Created by Sun on 2019/7/29.
//

//  Base32 address format for native v0-16 witness outputs implementation
//  https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
//  Inspired by Pieter Wuille C++ implementation

import Foundation

/// Segregated Witness Address encoder/decoder
public class SegWitBech32 {
    // MARK: Properties

    private let bech32 = Bech32()
    private let hrp: String

    // MARK: Lifecycle

    public init(hrp: String) {
        self.hrp = hrp
    }

    // MARK: Functions

    /// Decode segwit address
    /// Without program version byte
    public func decode(addr: String) throws -> Data {
        let dec = try bech32.decode(addr)
        guard dec.hrp == hrp else {
            throw BinanceChainKit.CoderError.hrpMismatch(dec.hrp, hrp)
        }
        guard dec.checksum.count >= 1 else {
            throw BinanceChainKit.CoderError.checksumSizeTooLow
        }
        let conv = try convertBits(from: 5, to: 8, pad: false, idata: dec.checksum)
        guard conv.count >= 2, conv.count <= 40 else {
            throw BinanceChainKit.CoderError.dataSizeMismatch(conv.count)
        }
        return conv
    }

    /// Encode segwit address
    /// Without program version byte
    public func encode(program: Data) throws -> String {
        var enc = Data()
        try enc.append(convertBits(from: 8, to: 5, pad: true, idata: program))
        let result = bech32.encode(hrp, values: enc)
        guard let _ = try? decode(addr: result) else {
            throw BinanceChainKit.CoderError.encodingCheckFailed
        }
        return result
    }

    /// Convert from one power-of-2 number base to another
    private func convertBits(from: Int, to: Int, pad: Bool, idata: Data) throws -> Data {
        var acc = 0
        var bits = 0
        let maxv: Int = (1 << to) - 1
        let maxAcc: Int = (1 << (from + to - 1)) - 1
        var odata = Data()
        for ibyte in idata {
            acc = ((acc << from) | Int(ibyte)) & maxAcc
            bits += from
            while bits >= to {
                bits -= to
                odata.append(UInt8((acc >> bits) & maxv))
            }
        }
        if pad {
            if bits != 0 {
                odata.append(UInt8((acc << (to - bits)) & maxv))
            }
        } else if bits >= from || ((acc << (to - bits)) & maxv) != 0 {
            throw BinanceChainKit.CoderError.bitsConversionFailed
        }
        return odata
    }
}
