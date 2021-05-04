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
//  DGCAVerifier
//
//  Created by Yannick Spreen on 4/19/21.
//

import Foundation
import SwiftyJSON
import JSONSchema
import UIKit

enum ClaimKey: String {
  case HCERT = "-260"
  case EU_DGC_V1 = "1"
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
  case test = "Test"
  case vaccine = "Vaccine Shot"
  case recovery = "Recovery"
}

public enum HCertValidity {
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
  .recoveryStatements: ["r"],
]

public enum InfoSectionStyle {
  case normal
  case fixedWidthFont
}

public struct InfoSection {
  public var header: String
  public var content: String
  public var style = InfoSectionStyle.normal
}

public struct HCert {
  public static var publicKeyStorageDelegate: PublicKeyStorageDelegate?
  public static var PREFETCH_ALL_CODES = false

  public static let supportedPrefixes = [
    "HC1:"
  ]

  mutating func parseBodyV1() -> Bool {
    guard
      let schema = JSON(parseJSON: EU_DGC_SCHEMA_V1).dictionaryObject,
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
    print(header)
    #if DEBUG
    print(body)
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
    if body[ClaimKey.HCERT.rawValue].exists() {
      body = body[ClaimKey.HCERT.rawValue]
    }
    if body[ClaimKey.EU_DGC_V1.rawValue].exists() {
      self.body = body[ClaimKey.EU_DGC_V1.rawValue]
      if !parseBodyV1() {
        return nil
      }
    } else {
      print("Wrong EU_DGC Version!")
      return nil
    }
    if Self.PREFETCH_ALL_CODES {
      prefetchCode()
    }
  }

  func get(_ attribute: AttributeKey) -> JSON {
    var object = body
    for key in attributeKeys[attribute] ?? [] {
      object = object[key]
    }
    return object
  }

  public var certTypeString: String {
    type.rawValue + " \(statement.typeAddon)"
  }

  public var info: [InfoSection] {
    var info = [
      InfoSection(
        header: "Certificate Type",
        content: certTypeString
      ),
    ] + personIdentifiers
    if let date = dateOfBirth {
      info += [
        InfoSection(
          header: "Date of Birth",
          content: date.localDateString
        ),
      ]
    }
    if let last = get(.lastNameStandardized).string {
      info += [
        InfoSection(
          header: "Standardised Family Name",
          content: last.replacingOccurrences(
            of: "<",
            with: String.zeroWidthSpace + "<" + String.zeroWidthSpace),
          style: .fixedWidthFont
        ),
      ]
    }
    if let first = get(.firstNameStandardized).string {
      info += [
        InfoSection(
          header: "Standardised Given Name",
          content: first.replacingOccurrences(
            of: "<",
            with: String.zeroWidthSpace + "<" + String.zeroWidthSpace),
          style: .fixedWidthFont
        ),
      ]
    }
    return info + statement.info
  }

  var shortPayload: String {
    return SHA256.digest(
      input: Data(payloadString.encode()) as NSData
    ).base64EncodedString()
  }
  public var payloadString: String
  public var cborData: Data
  public var kidStr: String
  public var header: JSON
  public var body: JSON

  var qrCodeRendered: UIImage? {
    Self.cachedQrCodes[shortPayload]
  }

  public var qrCode: UIImage? {
    return qrCodeRendered ?? renderQrCode()
  }

  static let qrLock = NSLock()
  func renderQrCode() -> UIImage? {
    if let rendered = qrCodeRendered {
      return rendered
    }
    let code = makeQrCode()
    if let value = code {
      Self.qrLock.lock()
      Self.cachedQrCodes[shortPayload] = value
      Self.qrLock.unlock()
    }
    return code
  }

  func makeQrCode() -> UIImage? {
    let data = payloadString.data(using: String.Encoding.ascii)

    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)

      if let output = filter.outputImage?.transformed(by: transform) {
        return UIImage(ciImage: output)
      }
    }

    return nil
  }

  func prefetchCode() {
    guard qrCodeRendered == nil else {
      return
    }
    DispatchQueue.global(qos: .background).async {
      _ = renderQrCode()
    }
  }

  static var cachedQrCodes = [String: UIImage]()

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
    /// Note from author: Identifiers were previously planned, but got removed *for now*.
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
  public var isValid: Bool {
    cryptographicallyValid && semanticallyValid
  }
  public var cryptographicallyValid: Bool {
    guard
      let delegate = Self.publicKeyStorageDelegate,
      let key = delegate.getEncodedPublicKey(for: kidStr)
    else {
      return false
    }
    return COSE.verify(cborData, with: key)
  }
  public var semanticallyValid: Bool {
    statement.isValid
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
