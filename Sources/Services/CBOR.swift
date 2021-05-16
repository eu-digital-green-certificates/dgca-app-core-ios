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
//  CBOR.swift
//
//
//  Created by Yannick Spreen on 4/15/21.
//

import Foundation
import SwiftCBOR

struct UnwrappedCBOR {
  let payload: SwiftCBOR.CBOR
  let protected: SwiftCBOR.CBOR
  let unprotected: [SwiftCBOR.CBOR: SwiftCBOR.CBOR]
}

public struct CBOR {
  static func unwrap(data: Data) -> UnwrappedCBOR? {
    let decoder = SwiftCBOR.CBORDecoder(input: data.uint)

    guard
      let cbor = try? decoder.decodeItem(),
      case let SwiftCBOR.CBOR.tagged(tag, cborElement) = cbor,
      tag.rawValue == coseTag, // SIGN1
      case let SwiftCBOR.CBOR.array(array) = cborElement,
      case let SwiftCBOR.CBOR.byteString(protectedBytes) = array[0],
      let protected = try? SwiftCBOR.CBOR.decode(protectedBytes),
      case let SwiftCBOR.CBOR.map(unprotectedMap) = array[1],
      case let SwiftCBOR.CBOR.byteString(payloadBytes) = array[2],
      let payload = try? SwiftCBOR.CBOR.decode(payloadBytes)
    else {
      return nil
    }
    return .init(payload: payload, protected: protected, unprotected: unprotectedMap)
  }

  public static func payload(from data: Data) -> SwiftCBOR.CBOR? {
    return unwrap(data: data)?.payload
  }

  public static func header(from data: Data) -> SwiftCBOR.CBOR? {
    return unwrap(data: data)?.protected
  }

  public static func kid(from data: Data) -> [UInt8]? {
    let cosePhdrKid = SwiftCBOR.CBOR.unsignedInt(4)

    let unwrap = unwrap(data: data)
    guard
      let protected = unwrap?.protected,
      case let SwiftCBOR.CBOR.map(protectedMap) = protected,
      let unprotected = unwrap?.unprotected
    else {
      return nil
    }
    let kid = protectedMap[cosePhdrKid] ?? (unprotected[cosePhdrKid] ?? .null)
    switch kid {
    case let .byteString(uint):
      return uint
    default:
      return nil
    }
  }

  public static func hash(from cborData: Data) -> String {
    let decoder = SwiftCBOR.CBORDecoder(input: cborData.uint)

    guard
      let cbor = try? decoder.decodeItem(),
      let data = COSE.signedPayloadBytes(from: cbor)
    else {
      return ""
    }
    return SHA256.digest(input: data as NSData).base64EncodedString()
  }
}
