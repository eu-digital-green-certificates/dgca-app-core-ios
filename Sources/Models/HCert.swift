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
//  HCert.swift
//
//
//  Created by Yannick Spreen on 4/19/21.
//

import Foundation
import SwiftyJSON
import JSONSchema

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

public enum HCertType: String {
  case test
  case vaccine
  case recovery
}

public enum HCertValidity: String {
  case valid
  case invalid
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

public struct InfoSection {
  public var header: String
  public var content: String
  public var style = InfoSectionStyle.normal
  public var isPrivate = false
}

public struct HCertConfig {
  public var prefetchAllCodes = false
  public var checkSignatures = true
}

public struct HCert {
  public static var config = HCertConfig()
  public static var publicKeyStorageDelegate: PublicKeyStorageDelegate?
  public static let supportedPrefixes = [
    "HC1:"
  ]

  mutating func parseBodyV1() -> Bool {
    guard
      let schema = JSON(parseJSON: euDgcSchemaV1).dictionaryObject,
      let bodyDict = body.dictionaryObject
    else {
      return false
    }

    guard
      let validation = try? validate(bodyDict, schema: schema)
    else {
      return false
    }
    #if DEBUG
    if let errors = validation.errors {
      for err in errors {
        print(err.description)
      }
    }
    #else
    if !validation.valid {
      return false
    }
    #endif
    return true
  }

  public init?(from payloadString: String) {
    var payloadString = payloadString
    for prefix in Self.supportedPrefixes {
      if payloadString.starts(with: prefix) {
        payloadString = String(payloadString.dropFirst(prefix.count))
      }
    }
    self.payloadString = payloadString

    guard
      let compressed = try? payloadString.fromBase45()
    else {
      return nil
    }

    cborData = decompress(compressed)
    guard
      let headerStr = CBOR.header(from: cborData)?.toString(),
      let bodyStr = CBOR.payload(from: cborData)?.toString(),
      let kid = CBOR.kid(from: cborData)
    else {
      return nil
    }
    kidStr = KID.string(from: kid)
    header = JSON(parseJSON: headerStr)
    var body = JSON(parseJSON: bodyStr)
    exp = Date(timeIntervalSince1970: Double(body["4"].int ?? 0))
    if body[ClaimKey.hCert.rawValue].exists() {
      body = body[ClaimKey.hCert.rawValue]
    }
    if body[ClaimKey.euDgcV1.rawValue].exists() {
      self.body = body[ClaimKey.euDgcV1.rawValue]
      if !parseBodyV1() {
        return nil
      }
    } else {
      print("Wrong EU_DGC Version!")
      return nil
    }
    findValidity()
    makeSections()

    #if os(iOS)
    if Self.config.prefetchAllCodes {
      prefetchCode()
    }
    #endif
  }

  mutating func findValidity() {
    validityFailures = []
    if !cryptographicallyValid {
      validityFailures.append(l10n("hcert.err.crypto"))
    }
    if exp < Date() {
      validityFailures.append(l10n("hcert.err.exp"))
    }
    validityFailures.append(contentsOf: statement.validityFailures)
  }

  mutating func makeSections() {
    info = isValid ? [] : [
      InfoSection(header: l10n("header.validity-errors"), content: validityFailures.joined(separator: " "))
    ]
    info += [
      InfoSection(
        header: l10n("header.cert-type"),
        content: certTypeString
      )
    ] + personIdentifiers
    if let date = dateOfBirth {
      info += [
        InfoSection(
          header: l10n("header.dob"),
          content: date.localDateString
        )
      ]
    }
    if let last = get(.lastNameStandardized).string {
      info += [
        InfoSection(
          header: l10n("header.std-fn"),
          content: last.replacingOccurrences(
            of: "<",
            with: String.zeroWidthSpace + "<" + String.zeroWidthSpace),
          style: .fixedWidthFont
        )
      ]
    }
    if let first = get(.firstNameStandardized).string {
      info += [
        InfoSection(
          header: l10n("header.std-gn"),
          content: first.replacingOccurrences(
            of: "<",
            with: String.zeroWidthSpace + "<" + String.zeroWidthSpace),
          style: .fixedWidthFont
        )
      ]
    }
    info += statement.info + [
      InfoSection(
        header: l10n("header.expires-at"),
        content: exp.dateTimeStringUtc
      ),
      InfoSection(
        header: l10n("header.uvci"),
        content: uvci,
        style: .fixedWidthFont,
        isPrivate: true
      )
    ]
  }

  func get(_ attribute: AttributeKey) -> JSON {
    var object = body
    for key in attributeKeys[attribute] ?? [] {
      object = object[key]
    }
    return object
  }

  public var certTypeString: String {
    type.l10n + " \(statement.typeAddon)"
  }

  public var info = [InfoSection]()

  public var payloadString: String
  public var cborData: Data
  public var kidStr: String
  public var header: JSON
  public var body: JSON
  public var exp: Date

  static let qrLock = NSLock()

  public var fullName: String {
    let first = get(.firstName).string ?? ""
    let last = get(.lastName).string ?? ""
    return "\(first) \(last)"
  }

  public var dateOfBirth: Date? {
    guard let dateString = get(.dateOfBirth).string else {
      return nil
    }
    return Date(dateString: dateString)
  }

  var personIdentifiers: [InfoSection] {
    // Note from author: Identifiers were previously planned, but got removed *for now*.
    []
  }

  var testStatements: [TestEntry] {
    return get(.testStatements)
      .array?
      .compactMap {
        TestEntry(body: $0)
      } ?? []
  }
  var vaccineStatements: [VaccinationEntry] {
    return get(.vaccineStatements)
      .array?
      .compactMap {
        VaccinationEntry(body: $0)
      } ?? []
  }
  var recoveryStatements: [RecoveryEntry] {
    return get(.recoveryStatements)
      .array?
      .compactMap {
        RecoveryEntry(body: $0)
      } ?? []
  }
  var statements: [HCertEntry] {
    testStatements + vaccineStatements + recoveryStatements
  }
  public var statement: HCertEntry! {
    statements.last
  }
  public var type: HCertType {
    if statement is VaccinationEntry {
      return .vaccine
    }
    if statement is RecoveryEntry {
      return .recovery
    }
    return .test
  }
  public var validityFailures = [String]()
  public var isValid: Bool {
    validityFailures.isEmpty
  }
  public var cryptographicallyValid: Bool {
    if !Self.config.checkSignatures {
      return true
    }
    guard
      let delegate = Self.publicKeyStorageDelegate
    else {
      return false
    }
    for key in delegate.getEncodedPublicKeys(for: kidStr) {
      if COSE.verify(cborData, with: key) {
        return true
      }
    }
    return false
  }
  public var validity: HCertValidity {
    return isValid ? .valid : .invalid
  }
  public var certHash: String {
    CBOR.hash(from: cborData)
  }
  public var uvci: String {
    statement.uvci
  }
  public var keyPair: SecKey! {
    Enclave.loadOrGenerateKey(with: uvci)
  }
}
