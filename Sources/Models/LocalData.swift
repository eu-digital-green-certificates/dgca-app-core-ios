//
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
//  LocalData.swift
//  
//
//  Created by Denis Melenevsky on 22.12.2021.
//

import Foundation

public class LocalData: Codable {
  public var certStrings = [DatedCertString]()
  public var lastFetchRaw: Date?
  public var lastFetch: Date {
    get {
      lastFetchRaw ?? Date.distantPast
    }
    set {
      lastFetchRaw = newValue
    }
  }
  public var config = Config.load()
  public var lastLaunchedAppVersion = "0.0"
}
