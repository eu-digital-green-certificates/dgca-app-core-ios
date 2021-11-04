/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-verifier-app-ios
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
//  CountryModel.swift
//  
//
//  Created by Alexandr Chernyy on 17.06.2021.
//

import Foundation

public class CountryModel: Codable {
  public let code: String
  public var debugModeEnabled: Bool

  public var name: String {
    get { l10n("country.\(code.uppercased())")}
  }

  public init(code: String, debugModeEnabled: Bool = false) {
    self.code = code
    self.debugModeEnabled = debugModeEnabled
  }
  
  enum CodingKeys: String, CodingKey {
    case code = "code", debugModeEnabled
  }
  
  // Init Rule from JSON Data
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decode(String.self, forKey: .code)
    debugModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .debugModeEnabled) ?? false
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(code, forKey: .code)
    try container.encode(debugModeEnabled, forKey: .debugModeEnabled)
  }
}
