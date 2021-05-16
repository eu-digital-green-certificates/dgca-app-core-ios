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
//  X509.swift
//
//
//  Created by Yannick Spreen on 4/17/21.
//

import Foundation

public struct X509 {
  public static func pubKey(from b64EncodedCert: String) -> SecKey? {
    guard
      let encodedCertData = Data(base64Encoded: b64EncodedCert),
      let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
      let publicKey = SecCertificateCopyKey(cert)
    else {
      return nil
    }
    return publicKey
  }

  public static func derPubKey(for secKey: SecKey) -> Data? {
    guard
      let pubKey = SecKeyCopyPublicKey(secKey)
    else {
      return nil
    }
    return derKey(for: pubKey)
  }

  public static func derKey(for secKey: SecKey) -> Data? {
    var error: Unmanaged<CFError>?
    guard
      let publicKeyData = SecKeyCopyExternalRepresentation(secKey, &error)
    else {
      return nil
    }
    return exportECPublicKeyToDER(publicKeyData as Data, keyType: kSecAttrKeyTypeEC as String, keySize: 384)
  }

  static func exportECPublicKeyToDER(_ rawPublicKeyBytes: Data, keyType: String, keySize: Int) -> Data {
    let curveOIDHeader: [UInt8] = [
      0x30,
      0x59,
      0x30,
      0x13,
      0x06,
      0x07,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x02,
      0x01,
      0x06,
      0x08,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x03,
      0x01,
      0x07,
      0x03,
      0x42,
      0x00
    ]
    var data = Data(bytes: curveOIDHeader, count: curveOIDHeader.count)
    data.append(rawPublicKeyBytes)
    return data
  }
}
