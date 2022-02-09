//
//  BloomFilter+Hasher.swift
//  
//
//  Created by Paul Ballmann on 26.01.22.
//

import Foundation
import CryptoKit

extension BloomFilter {
	/**
	 Takes either a string or a byte array and hashes it with the given hashFunction
	 */
    public class func hash(data: Data, seed: UInt8) -> Data {

        let seedBytes = Data(withUnsafeBytes(of: seed, Array.init))
        var hashData = Data(data)
        hashData.append(seedBytes)
        
        return SHA256.sha256(data: hashData)
    }
}

