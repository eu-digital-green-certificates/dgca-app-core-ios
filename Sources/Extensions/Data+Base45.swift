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
//  Data+Base45.swift
//
//
//  Created by Yannick Spreen on 4/21/21.
//

import Foundation

extension Data {
  public func toBase45() -> String {
    var out = String()
    for num in stride(from: 0, to: count, by: 2) {
      if self.count - num > 1 {
        let numX: Int = (Int(self[num]) << 8) + Int(self[num + 1])
        let numE: Int = numX / (45 * 45)
        let numY: Int = numX % (45 * 45)
        let numD: Int = numY / 45
        let numC: Int = numY % 45
        out.append(b45Charset[numC])
        out.append(b45Charset[numD])
        out.append(b45Charset[numE])
      } else {
        let numY: Int = Int(self[num])
        let numD: Int = numY / 45
        let numC: Int = numY % 45
        out.append(b45Charset[numC])
        out.append(b45Charset[numD])
      }
    }
    return out
  }
}
