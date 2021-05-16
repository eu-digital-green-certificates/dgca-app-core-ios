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
//  Data+hexString.swift
//
//
//  Created by Yannick Spreen on 4/14/21.
//

import Foundation

public extension Data {
  init?(hexString: String) {
    let len = hexString.count / 2
    var data = Data(capacity: len)
    var numX = hexString.startIndex
    for _ in 0..<len {
      let numY = hexString.index(numX, offsetBy: 2)
      let bytes = hexString[numX..<numY]
      if var num = UInt8(bytes, radix: 16) {
        data.append(&num, count: 1)
      } else {
        return nil
      }
      numX = numY
    }
    self = data
  }

  var uint: [UInt8] { [UInt8](self) }
  var hexString: String {
    let format = "%02hhx"
    return self.map { String(format: format, $0) }.joined()
  }
}
