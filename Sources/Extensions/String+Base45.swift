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
//  Base45.swift
//
//  Created by Dirk-Willem van Gulik on 01/04/2021.
//

import Foundation

let b45Charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"

extension String {
  enum Base45Error: Error {
    case base64InvalidCharacter
    case base64InvalidLength
  }

  public func fromBase45() throws -> Data {
    var dData = Data()
    var oData = Data()

    for char in self.uppercased() {
      if let index = b45Charset.firstIndex(of: char) {
        let idx = b45Charset.distance(from: b45Charset.startIndex, to: index)
        dData.append(UInt8(idx))
      } else {
        throw Base45Error.base64InvalidCharacter
      }
    }
    for num in stride(from: 0, to: dData.count, by: 3) {
      if dData.count - num < 2 {
        throw Base45Error.base64InvalidLength
      }
      var xNum: UInt32 = UInt32(dData[num]) + UInt32(dData[num + 1]) * 45
      if dData.count - num >= 3 {
        xNum += 45 * 45 * UInt32(dData[num + 2])
        if xNum >= 256 * 256 {
          throw Base45Error.base64InvalidCharacter
        }
        oData.append(UInt8(xNum / 256))
      }
      oData.append(UInt8(xNum % 256))
    }
    return oData
  }
}
