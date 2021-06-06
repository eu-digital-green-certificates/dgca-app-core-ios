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
//  COSE.swift
//
//
//  Created by Yannick Spreen on 4/14/21.
//

import Foundation
import SwiftCBOR

public struct COSE {
    public static func verify(_cbor:Data, with derPubKeyB64: String) -> Bool {
        guard let sign = CBOR.unwrap(data: _cbor)?.signatureBytes else {return false};
        guard let bytes = signedPayloadBytes(from: _cbor) ?? nil else { return false };
        guard let key = X509.pubKey(from: derPubKeyB64) else {
           return false
         }
        return Signature.verify(Data(bytes: sign),for: bytes,with: key)
  }

  public static func signedPayloadBytes(from cbor: Data) -> Data? {
    guard let unwrapped = CBOR.unwrap(data: cbor) else {return nil};

    let signedPayload: [UInt8] = SwiftCBOR.CBOR.encode(
      [
        "Signature1",
        SwiftCBOR.CBOR.byteString(unwrapped.protectedBytes) ,
        SwiftCBOR.CBOR.byteString([]),
        SwiftCBOR.CBOR.byteString(unwrapped.payloadBytes) ,
      ]
    )
    return Data(signedPayload)
  }
}
