//
//  File.swift
//  
//
//  Created by Igor Khomiak on 15.10.2021.
//

import Foundation
import SwiftyJSON

enum ClaimKey: String {
  case hCert = "-260"
  case euDgcV1 = "1"
}

enum AttributeKey: String {
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
}

let attributeKeys: [AttributeKey: [String]] = [
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

public enum RuleValidationResult: Int {
  case error = 0
  case passed
  case open
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
