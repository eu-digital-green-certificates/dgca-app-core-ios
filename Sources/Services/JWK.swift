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
//  JWK.swift
//
//
//  Created by Yannick Spreen on 4/13/21.
//
//  https://medium.com/@vaibhav.pmeshram/creating-and-dismantling-ec-key-in-swift-f5bde8cb633f
//

import Foundation

struct JWK {
  public static func ecFrom(x numX: String, y numY: String) -> SecKey? {
    var xBytes: Data?
    var yBytes: Data?
    if (numX + numY).count == 128 {
      xBytes = Data(hexString: numX)
      yBytes = Data(hexString: numY)
    } else {
      var xStr = numX // Base64 Formatted data
      var yStr = numY

      xStr = xStr.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
      while xStr.count % 4 != 0 {
        xStr.append("=")
      }
      yStr = yStr.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
      while yStr.count % 4 != 0 {
        yStr.append("=")
      }
      xBytes = Data(base64Encoded: xStr)
      yBytes = Data(base64Encoded: yStr)
    }

    // Now this bytes we have to append such that [0x04 , /* xBytes */, /* yBytes */]
    // Initial byte for uncompressed y as Key.
    let keyData = NSMutableData.init(bytes: [0x04], length: 1)
    keyData.append(xBytes ?? Data())
    keyData.append(yBytes ?? Data())
    let attributes: [String: Any] = [
      String(kSecAttrKeyType): kSecAttrKeyTypeEC,
      String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
      String(kSecAttrKeySizeInBits): 256,
      String(kSecAttrIsPermanent): false
    ]
    var error: Unmanaged<CFError>?
    let keyReference = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error)
    let errorString = error?.takeUnretainedValue().localizedDescription ?? l10n("err.misc")
    error?.release()
    guard
      let key = keyReference
    else {
      print(errorString)
      return nil
    }

    return key
  }
}
