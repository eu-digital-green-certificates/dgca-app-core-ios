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
//  Enums.swift
//  
//
//  Created by Igor Khomiak on 15.10.2021.
//

import Foundation

public enum ClaimKey: String {
  case hCert = "-260"
  case euDgcV1 = "1"
}

public enum AttributeKey: String {
  case firstName
  case lastName
  case firstNameStandardized
  case lastNameStandardized
  case gender
  case dateOfBirth
  case testStatements
  case vaccineStatements
  case recoveryStatements
}

public enum AppType: Int {
  case verifier
  case wallet
}

public enum HCertType: String {
  case test
  case vaccine
  case recovery
  case unknown
}

public enum HCertValidity {
    case valid
    case invalid
    case ruleInvalid
    case revoked
}

public let attributeKeys: [AttributeKey: [String]] = [
  .firstName: ["nam", "gn"],
  .lastName: ["nam", "fn"],
  .firstNameStandardized: ["nam", "gnt"],
  .lastNameStandardized: ["nam", "fnt"],
  .dateOfBirth: ["dob"],
  .testStatements: ["t"],
  .vaccineStatements: ["v"],
  .recoveryStatements: ["r"]
]

public enum InfoSectionStyle {
  case normal
  case fixedWidthFont
}

public class ParseErrors {
  var errors: [ParseError] = []
}

public enum ParseError {
  case base45
  case prefix
  case zlib
  case cbor
  case json(error: String)
  case version(error: String)
}

public enum CertificateParsingError: Error {
    case unknown
    case parsing(errors: [ParseError])
}

public enum RevocationMode: String {
    case point = "POINT"
    case vector = "VECTOR"
    case coordinate = "COORDINATE"
    
    public func partitionOffset() -> UInt8 {
        switch self {
        case .point:
            return 0
        case .vector:
            return 8
        case .coordinate:
            return 16
       }
    }
}

public var sliceType: SliceType = .BLOOMFILTER

public enum SliceType: String {
   case BLOOMFILTER, VARHASHLIST
}
