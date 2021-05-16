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
//  JSON.swift
//  
//
//  Created by Yannick Spreen on 5/12/21.
//

import SwiftyJSON

public extension JSON {
  init(parseJSONC json: String) {
    let json = json.replacingOccurrences(of: "\r", with: "\n").split(separator: "\n").filter {
      !$0.trimmingCharacters(in: [" ", "\t"]).starts(with: "//")
    }.joined(separator: "\n")
    self = JSON(parseJSON: json)
  }

  mutating func merge(other: JSON) {
    if self.type == other.type {
      switch self.type {
      case .dictionary:
        for (key, _) in other {
          self[key].merge(other: other[key])
        }
      default:
        self = other
      }
    } else {
      self = other
    }
  }

  func mergeAndOverride(other: JSON) -> JSON {
    var merged = self
    merged.merge(other: other)
    return merged
  }
}
