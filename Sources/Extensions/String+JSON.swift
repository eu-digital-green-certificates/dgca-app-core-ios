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
//  String+JSON.swift
//
//
//  Created by Yannick Spreen on 4/13/21.
//

import Foundation

extension String {
  var asJSONDict: [String: AnyObject] {
    if let data = data(using: .utf8) {
      do {
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
        return json ?? [:]
      } catch {
        return [:]
      }
    }
    return [:]
  }
}
