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

public enum HCertValidity: String {
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

public struct InfoSection {
  public var header: String
  public var content: String
  public var style = InfoSectionStyle.normal
  public var isPrivate = false
  public var sectionItems: [InfoSection] = []
  public var isExpanded: Bool = false
  public var countryName: String?
  public var ruleValidationResult: RuleValidationResult = .open
  
  public init(header: String, content: String, style: InfoSectionStyle = .normal, isPrivate: Bool = false,  countryName: String? = nil, ruleValidationResult: RuleValidationResult = .open) {
    self.header = header
    self.content = content
    self.countryName = countryName
    self.style = style
    self.isPrivate = isPrivate
    self.ruleValidationResult = ruleValidationResult
  }
}

public struct HCertConfig {
  public var prefetchAllCodes = false
  public var checkSignatures = true
}

public struct HCert {
  public enum ParseError {
    case base45
    case prefix
    case zlib
    case cbor
    case json(error: String)
    case version
  }
  public class ParseErrors {
    var errors: [ParseError] = []
  }
  
  public static var debugPrintJsonErrors = true
  public static var config = HCertConfig()
  public static var publicKeyStorageDelegate: PublicKeyStorageDelegate?
  public static let supportedPrefixes = [
    "HC1:"
  ]
  
  public var appType: AppType = .verifier
  
  static func parsePrefix(_ payloadString: String) -> String {
    var payloadString = payloadString
    Self.supportedPrefixes.forEach({ prefix in
      if payloadString.starts(with: prefix) {
        payloadString = String(payloadString.dropFirst(prefix.count))
      }
    })
    return payloadString
  }
  
  static private func checkCH1PreffixExist(_ payloadString: String?) -> Bool {
    guard let payloadString = payloadString  else { return false }
    var foundPrefix = false
    Self.supportedPrefixes.forEach { prefix in
      if payloadString.starts(with: prefix) { foundPrefix = true }
    }
    return foundPrefix
  }
  
  public init?(from payload: String, errors: ParseErrors? = nil, applicationType: AppType = .verifier) {
    
    let payload = payload
    if Self.checkCH1PreffixExist(payload) {
      fullPayloadString = payload
      payloadString = Self.parsePrefix(payload)
    } else {
      fullPayloadString = Self.supportedPrefixes.first ?? ""
      fullPayloadString = fullPayloadString + payload
      payloadString = payload
    }
    appType = applicationType
    
    guard
      let compressed = try? payloadString.fromBase45()
    else {
      errors?.errors.append(.base45)
      return nil
    }
    
    cborData = decompress(compressed)
    if cborData.isEmpty {
      errors?.errors.append(.zlib)
    }
    guard
      let headerStr = CBOR.header(from: cborData)?.toString(),
      let bodyStr = CBOR.payload(from: cborData)?.toString(),
      let kid = CBOR.kid(from: cborData)
    else {
      errors?.errors.append(.cbor)
      return nil
    }
    kidStr = KID.string(from: kid)
    header = JSON(parseJSON: headerStr)
    var body = JSON(parseJSON: bodyStr)
    iat = Date(timeIntervalSince1970: Double(body["6"].int ?? 0))
    exp = Date(timeIntervalSince1970: Double(body["4"].int ?? 0))
    issCode = body["1"].string ?? ""
    if body[ClaimKey.hCert.rawValue].exists() {
      body = body[ClaimKey.hCert.rawValue]
    }
    if body[ClaimKey.euDgcV1.rawValue].exists() {
      self.body = body[ClaimKey.euDgcV1.rawValue]
      if !parseBodyV1(errors: errors) {
        return nil
      }
    } else {
      print("Wrong EU_DGC Version!")
      errors?.errors.append(.version)
      return nil
    }
    findValidity()
    makeSections(for: appType)
    
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
    if exp < HCert.clock {
      validityFailures.append(l10n("hcert.err.exp"))
    }
    if iat > HCert.clock {
      validityFailures.append(l10n("hcert.err.iat"))
    }
    if statement == nil {
      return validityFailures.append(l10n("hcert.err.empty"))
    }
    validityFailures.append(contentsOf: statement.validityFailures)
  }
  
  //
  public mutating func makeSectionForRuleError(infoSections: InfoSection, for appType: AppType) {
    info.removeAll()
    info = isValid ? [] : [
      InfoSection(header: l10n("header.validity-errors"), content: validityFailures.joined(separator: " "))
    ]
    info += [
      InfoSection(
        header: l10n("header.cert-type"),
        content: certTypeString
      )
    ] + personIdentifiers
    info += [infoSections]
    switch appType {
    case .verifier:
        makeSectionsForVerifier(includeInvalidSection: false)
    case .wallet:
      switch type {
        case .vaccine:
          makeSectionsForVaccine(includeInvalidSection: false)
          break
      case .test:
        makeSectionsForTest()
        break
      case .recovery:
        makeSectionsForRecovery(includeInvalidSection: false)
        break
        default:
          makeSectionsForVerifier(includeInvalidSection: false)
        }
      break
    }
  }

  //
  
  mutating func makeSections(for appType: AppType) {
    info.removeAll()
    switch appType {
    case .verifier:
        makeSectionsForVerifier()
    case .wallet:
      switch type {
        case .vaccine:
          makeSectionsForVaccine()
          break
      case .test:
        makeSectionsForTest()
        break
      case .recovery:
        makeSectionsForRecovery()
        break
        default:
          makeSectionsForVerifier()
        }
      break
    }
  }
  
  mutating func makeSectionsForVerifier(includeInvalidSection: Bool = true) {
    if includeInvalidSection {
      info = isValid ? [] : [
        InfoSection(header: l10n("header.validity-errors"), content: validityFailures.joined(separator: " "))
      ]
    }
    if includeInvalidSection {
      info += [
        InfoSection(
          header: l10n("header.cert-type"),
          content: certTypeString
        )
      ] + personIdentifiers
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
    if let date = get(.dateOfBirth).string {
      info += [
        InfoSection(
          header: l10n("header.dob"),
          content: date
        )
      ]
    }
    info += statement == nil ? [] : statement.info
    info += [
      InfoSection(
        header: l10n("header.uvci"),
        content: uvci,
        style: .fixedWidthFont,
        isPrivate: true
      )
    ]
    if issCode.count > 0 {
      info += [
        InfoSection(
          header: l10n("issuer.country"),
          content: l10n("country.\(issCode.uppercased())")
        )
      ]
    }
  }
  
  mutating func makeSectionsForVaccine(includeInvalidSection: Bool = true) {
    if includeInvalidSection {
      info = isValid ? [] : [
        InfoSection(header: l10n("header.validity-errors"), content: validityFailures.joined(separator: " "))
      ]
    }
    if includeInvalidSection {
      info += [
        InfoSection(
          header: l10n("header.cert-type"),
          content: certTypeString
        )
      ] + personIdentifiers
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
    info += statement == nil ? [] : statement.walletInfo
    if issCode.count > 0 {
      info += [
        InfoSection(
          header: l10n("issuer.country"),
          content: l10n("country.\(issCode.uppercased())")
        )
      ]
    }
  }
  
  mutating func makeSectionsForTest(includeInvalidSection: Bool = true) {
    if includeInvalidSection {
      info = isValid ? [] : [
        InfoSection(header: l10n("header.validity-errors"), content: validityFailures.joined(separator: " "))
      ]
    }
    if includeInvalidSection {
      info += [
        InfoSection(
          header: l10n("header.cert-type"),
          content: certTypeString
        )
      ] + personIdentifiers
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
    info += statement == nil ? [] : statement.walletInfo
    if issCode.count > 0 {
      info += [
        InfoSection(
          header: l10n("issuer.country"),
          content: l10n("country.\(issCode.uppercased())")
        )
      ]
    }
  }

  mutating func makeSectionsForRecovery(includeInvalidSection: Bool = true) {
    if includeInvalidSection {
      info = isValid ? [] : [
      InfoSection(header: l10n("header.validity-errors"), content: validityFailures.joined(separator: " "))
      ]
    }
    if includeInvalidSection {
      info += [
        InfoSection(
          header: l10n("header.cert-type"),
          content: certTypeString
        )
      ] + personIdentifiers
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
    info += statement == nil ? [] : statement.walletInfo
    if issCode.count > 0 {
      info += [
        InfoSection(
          header: l10n("issuer.country"),
          content: l10n("country.\(issCode.uppercased())")
        )
      ]
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
    type.l10n + (statement == nil ? "" : " \(statement.typeAddon)")
  }
  
  public var info = [InfoSection]()
  
  public var fullPayloadString: String
  public var payloadString: String
  public var cborData: Data
  public var kidStr: String
  public var issCode: String
  public var header: JSON
  public var body: JSON
  public var iat: Date
  public var exp: Date
  public var ruleCountryCode: String?
  
  static let qrLock = NSLock()
  
  public var fullName: String {
    let first = get(.firstName).string ?? ""
    let last = get(.lastName).string ?? ""
    return "\(first) \(last)"
  }
  
  public var dateOfBirth: String {
    let dob = get(.dateOfBirth).string ?? ""
    return "\(dob)"
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
    
    if statement is TestEntry {
      return .test
    }
    return .unknown
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
      if !X509.isCertificateValid(cert: key) {
        return false
      }
      if X509.checkisSuitable(cert:key,certType:type) {
        if COSE.verify(_cbor: cborData, with: key) {
          return true
        } else {
          return false
        }
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
    statement?.uvci ?? "empty"
  }
  public var keyPair: SecKey! {
    Enclave.loadOrGenerateKey(with: uvci)
  }
  public static var clock: Date {
    clockOverride ?? Date()
  }
  public static var clockOverride: Date?
}
