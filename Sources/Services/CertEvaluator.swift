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
//  CertEvaluator.swift
//
//
//  Created by Yannick Spreen on 5/12/21.
//

import Foundation
import Alamofire

public struct CertEvaluator: ServerTrustEvaluating {
  class CertError: Error {}

  let pubKeys: [String]

  public func evaluate(_ trust: SecTrust, forHost host: String) throws {
    let hashes: [String] = trust.af.publicKeys.compactMap { key in
      guard
        let der = X509.derKey(for: key)
      else {
        return nil
      }
      return SHA256.digest(input: der as NSData).base64EncodedString()
    }
    for hash in (hashes + ["*"]) {
      if pubKeys.contains(hash) {
        #if DEBUG && targetEnvironment(simulator)
        print("SSL Pubkey matches. ✅")
        #endif
        return
      }
    }
    #if !DEBUG || !targetEnvironment(simulator)
    throw Self.CertError()
    #endif
    print("\nFATAL: None of the hashes matched our public keys! These keys were loaded:")
    print(pubKeys.joined(separator: "\n"))
    print("\nThe server returned this chain:")
    print(hashes.joined(separator: "\n"))
  }

  public init(pubKeys: [String]) {
    self.pubKeys = pubKeys
  }

}
