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

public struct HCertConfig {
  public let prefetchAllCodes: Bool
  public let checkSignatures: Bool
}

public struct HCert {

  public static let config = HCertConfig(prefetchAllCodes: false, checkSignatures: true)
  public static let supportedPrefixes = [ "HC1:" ]
  
  public static var debugPrintJsonErrors = true
  public static var publicKeyStorageDelegate: PublicKeyStorageDelegate?

  public let appType: AppType
  public let fullPayloadString: String
  public let payloadString: String
  public let cborData: Data
  public let kidStr: String
  public let issCode: String
  public let header: JSON
  public let body: JSON
  public let iat: Date
  public let exp: Date
  public var ruleCountryCode: String?

  public var dateOfBirth: String {
    return get(.dateOfBirth).string ?? ""
  }
  public var firstName: String {
    return get(.firstName).string ?? ""
  }
  public var firstNameStandardized: String {
    return get(.firstNameStandardized).string ?? ""
  }
  public var lastName: String {
    return get(.lastName).string ?? ""
  }
  public var lastNameStandardized: String {
    return get(.lastNameStandardized).string ?? ""
  }
  public var fullName: String {
    var fullName = ""
    fullName = fullName + firstName.replacingOccurrences(of: "<",
      with: String.zeroWidthSpace + "<" + String.zeroWidthSpace)
    if !fullName.isEmpty {
        fullName = fullName + " " + lastName.replacingOccurrences( of: "<", with: String.zeroWidthSpace +
          "<" + String.zeroWidthSpace)
    } else {
      fullName = fullName + lastName.replacingOccurrences(of: "<",
        with: String.zeroWidthSpace + "<" + String.zeroWidthSpace)
    }
    if fullName.isEmpty {
      fullName = fullName + firstNameStandardized.replacingOccurrences( of: "<",
          with: String.zeroWidthSpace + "<" + String.zeroWidthSpace)
      if !fullName.isEmpty {
      fullName = fullName + " " + lastNameStandardized.replacingOccurrences( of: "<",
       with: String.zeroWidthSpace + "<" + String.zeroWidthSpace)
      } else {
        fullName = fullName + lastNameStandardized.replacingOccurrences( of: "<",
         with: String.zeroWidthSpace + "<" + String.zeroWidthSpace)
      }
    }
    return fullName
  }
  public var certTypeString: String {
    certificateType.l10n + (statement == nil ? "" : " \(statement.typeAddon)")
  }
  public var uvci: String {
    statement?.uvci ?? "empty"
  }
  public var certificateType: HCertType {
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
  var testStatements: [TestEntry] {
    return get(.testStatements).array?.compactMap {TestEntry(body: $0)} ?? []
  }
  var vaccineStatements: [VaccinationEntry] {
    return get(.vaccineStatements).array?.compactMap { VaccinationEntry(body: $0) } ?? []
  }
  var recoveryStatements: [RecoveryEntry] {
    return get(.recoveryStatements).array?.compactMap {RecoveryEntry(body: $0)} ?? []
  }
  var statements: [HCertEntry] {
    return testStatements + vaccineStatements + recoveryStatements
  }
  public var statement: HCertEntry! {
    return statements.last
  }
  public var cryptographicallyValid: Bool {
    if !Self.config.checkSignatures {
      return true
    }
    guard let delegate = Self.publicKeyStorageDelegate else { return false }
    
    for key in delegate.getEncodedPublicKeys(for: kidStr) {
      if !X509.isCertificateValid(cert: key) {
        return false
      }
      return X509.checkisSuitable(cert:key, certType: certificateType)
    }
    return false
  }
  public var certHash: String {
    CBOR.hash(from: cborData)
  }
  public var keyPair: SecKey! {
    Enclave.loadOrGenerateKey(with: uvci)
  }
  public static var clock: Date {
    clockOverride ?? Date()
  }
  public static var clockOverride: Date?

  static private func parsePrefix(_ payloadString: String) -> String {
    var payloadString = payloadString
    Self.supportedPrefixes.forEach({ supportedPrefix in
      if payloadString.starts(with: supportedPrefix) {
        payloadString = String(payloadString.dropFirst(supportedPrefix.count))
      }
    })
    return payloadString
  }

  static private func checkCH1PreffixExist(_ payloadString: String?) -> Bool {
    guard let payloadString = payloadString  else { return false }
    var foundPrefix = false
    Self.supportedPrefixes.forEach { supportedPrefix in
      if payloadString.starts(with: supportedPrefix) { foundPrefix = true }
    }
    return foundPrefix
  }
  
  public init?(from payload: String, errors: ParseErrors? = nil, applicationType: AppType = .verifier) {
    let payload = payload
    if Self.checkCH1PreffixExist(payload) {
      fullPayloadString = payload
      payloadString = Self.parsePrefix(payload)
    } else {
      let supportedPrefixesString = Self.supportedPrefixes.first ?? ""
      fullPayloadString = supportedPrefixesString + payload
      payloadString = payload
    }
    appType = applicationType
    
    guard let compressed = try? payloadString.fromBase45() else {
      errors?.errors.append(.base45)
      return nil
    }
    
    cborData = decompress(compressed)
    if cborData.isEmpty {
      errors?.errors.append(.zlib)
    }
    
    guard let headerStr = CBOR.header(from: cborData)?.toString(),
      let bodyStr = CBOR.payload(from: cborData)?.toString(),
      let kid = CBOR.kid(from: cborData) else {
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
    #if os(iOS)
    if Self.config.prefetchAllCodes {
      prefetchCode()
    }
    #endif
  }

 func get(_ attribute: AttributeKey) -> JSON {
    var object = body
    for key in attributeKeys[attribute] ?? [] {
      object = object[key]
    }
    return object
  }
}
