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
//  SwiftCBOR.CBOR.swift
//
//
//  Created by Yannick Spreen on 4/19/21.
//

import Foundation
import SwiftCBOR

extension SwiftCBOR.CBOR {
  
  func sanitize(value: String) -> String {
    return value.replacingOccurrences(of: "\"", with: "\\\"")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  func toString() -> String {
    switch self {
    case let .byteString(val):
      let fallBack = "[" + val.map { "\($0)" }.joined(separator: ", ") + "]"
      //      if
      //        let child = try? SwiftCBOR.CBOR.decode(val),
      //        case .map(_) = child
      //      {
      //        return child.toString()
      //      }
      return fallBack
    case let .unsignedInt(val):
      return "\(val)"
    case let .negativeInt(val):
      return "-\(val + 1)"
    case let .utf8String(val):
      return "\"\(sanitize(value: val))\""
    case let .array(vals):
      var str = ""
      for val in vals {
        str += (str.isEmpty ? "" : ", ") + val.toString()
      }
      return "[\(str)]"
    case let .map(vals):
      var str = ""
      for pair in vals {
        let val = pair.value
        if case .undefined = val {
          continue
        }
        let key = "\"\(pair.key.toString().trimmingCharacters(in: ["\""]))\""
        str += (str.isEmpty ? "" : ", ") + "\(key): \(val.toString())"
      }
      return "{\(str)}"
    case let .boolean(val):
      return String(describing: val)
    case .null, .undefined:
      return "null"
    case let .float(val):
      return "\(val)"
    case let .double(val):
      return "\(val)"
    case let .date(val):
      return "\"\(val.isoString)\""
    default:
      return "\"unsupported data\""
    }
  }
}
