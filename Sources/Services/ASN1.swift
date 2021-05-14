/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//
//  ASN1.swift
//  DGCAVerifier
//
//  Created by Yannick Spreen on 5/7/21.
//
//  Based on ASN1Encoder.swift in ehn-digital-green-development/ValidationCore
//  by Christian Kollmann
//

import Foundation

public class ASN1 {

  public static func encode(_ data: Data, _ digestLengthInBytes: Int? = nil) -> Data {
    let data = data.uint
    let digestLengthInBytes = digestLengthInBytes ?? 32 // for ES256
    let sigR = encodeInt([UInt8](data.prefix(data.count - digestLengthInBytes)))
    let sigS = encodeInt([UInt8](data.suffix(digestLengthInBytes)))
    let tagSequence: UInt8 = 0x30
    if sigR.count + sigS.count < 128 {
      return Data([tagSequence, UInt8(sigR.count + sigS.count)] + sigR + sigS)
    }
    return Data([tagSequence] + length(sigR.count + sigS.count) + sigR + sigS)
  }

  static func length(_ num: Int) -> [UInt8] {
    var bits = 0
    var numBits = num
    while numBits > 0 {
      numBits = numBits >> 1
      bits += 1
    }
    var bytes: [UInt8] = []
    var num = num
    while num > 0 {
      bytes += [UInt8(num & 0b11111111)]
      num = num >> 8
    }
    return [0b10000000 + UInt8((bits - 1) / 8 + 1)] + bytes.reversed()
  }

  private static func encodeInt(_ data: [UInt8]) -> [UInt8] {
    let firstBitIsSet: UInt8 = 0b10000000 // would be decoded as a negative number
    let tagInteger: UInt8 = 0x02
    if data[0] >= firstBitIsSet {
      return [tagInteger, UInt8(data.count + 1)] + [0] + data
    } else if data.first! == 0x00 {
      return encodeInt([UInt8](data.dropFirst()))
    } else {
      return [tagInteger, UInt8(data.count)] + data
    }
  }

  public static func decode(from data: Data) -> Data {
    var data = data.uint
    if data[0] == 0x30 {
      data = data.suffix(data.count - 2)
    }
    let cNum = Int(data[1])
    let rNum = decodeInt([UInt8](data.prefix(cNum + 2)))
    var sNum = decodeInt([UInt8](data.suffix(data.count - cNum - 2)))
    while sNum.count < 32 { // 32 for ES256
      sNum = [UInt8(0)] + sNum
    }
    return Data(rNum + sNum)
  }

  private static func decodeInt(_ data: [UInt8]) -> [UInt8] {
    var data = [UInt8](data.suffix(data.count - 2))
    while data[0] == 0 {
      data = [UInt8](data.suffix(data.count - 1))
    }
    return [UInt8](data)
  }

}
