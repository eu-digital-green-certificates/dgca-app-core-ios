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
//  HCertConfig.swift
//  
//
//  Created by Igor Khomiak on 20.10.2021.
//

import Foundation

public class HCertConfig {
  public static let `default` = HCertConfig()
  public static let supportedPrefixes = [ "HC1:" ]
    
  public let prefetchAllCodes: Bool
  public let checkSignatures: Bool
  public let debugPrintJsonErrors: Bool

  init() { // default
    self.prefetchAllCodes = false
    self.checkSignatures = true
    self.debugPrintJsonErrors = true
  }
  
  public init(prefetchAllCodes: Bool, checkSignatures: Bool, debugPrintJsonErrors: Bool) {
    self.prefetchAllCodes = prefetchAllCodes
    self.checkSignatures = checkSignatures
    self.debugPrintJsonErrors = debugPrintJsonErrors
  }

  public static func checkCH1PreffixExist(_ payloadString: String?) -> Bool {
    guard let payloadString = payloadString  else { return false }
    
    for prfix in supportedPrefixes {
      if payloadString.starts(with: prfix) {
        return true
      }
    }
    return false
  }
  
  public static func parsePrefix(_ payloadString: String) -> String {
    for prfix in supportedPrefixes {
      if payloadString.starts(with: prfix) {
        return String(payloadString.dropFirst(prfix.count))
      }
    }
    return payloadString
  }
}
