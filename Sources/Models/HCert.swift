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
import SwiftCBOR

public class HCert: Codable {
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
    public var isRevoked: Bool = false
    
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
        switch statement {
        case is VaccinationEntry:
            return .vaccine
        case is RecoveryEntry:
            return .recovery
        case is TestEntry:
            return .test
        default:
            return .unknown
        }
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
        if !CoreManager.config.checkSignatures {
            return true
        }
        guard let delegate = CoreManager.publicKeyEncoder else { return false }
        
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

    public init(from payload: String, ruleCountryCode: String? = nil) throws {
        var copyPayload = payload
        self.isRevoked = false
        if let firstChar = payload.first {
          if firstChar == "x" {
            self.isRevoked = true
              copyPayload.removeFirst()
            }
        }
        if HCertConfig.checkCH1PreffixExist(copyPayload) {
            fullPayloadString = copyPayload
            payloadString = HCertConfig.parsePrefix(copyPayload)
        } else {
          let supportedPrefix = HCertConfig.supportedPrefixes.first ?? ""
          fullPayloadString = supportedPrefix + copyPayload
          payloadString = copyPayload
        }
            
        self.ruleCountryCode = ruleCountryCode
        guard let compressed = try? payloadString.fromBase45() else {
            throw CertificateParsingError.parsing(errors: [ParseError.base45])
        }
        
        var parsingErrors = [ParseError]()
        cborData = ZLib.decompress(compressed)
        if cborData.isEmpty {
            parsingErrors.append(ParseError.zlib)
        }
        guard let headerStr = CBOR.header(from: cborData)?.toString(),
            let bodyStr = CBOR.payload(from: cborData)?.toString(),
            let kid = CBOR.kid(from: cborData) else {
            parsingErrors.append(ParseError.cbor)
            throw CertificateParsingError.parsing(errors: parsingErrors)
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
            let parseBodyErrors = parseBodyV1()
            if !parseBodyErrors.isEmpty {
                throw CertificateParsingError.parsing(errors: parsingErrors)
            }
        } else {
            print("Wrong EU_DGC Version!")
            parsingErrors.append(.version(error: "Wrong EU_DGC Version!"))
            throw CertificateParsingError.parsing(errors: parsingErrors)
        }
    }
    
    private func get(_ attribute: AttributeKey) -> JSON {
        var object = body
        for key in attributeKeys[attribute] ?? [] {
            object = object[key]
        }
        return object
    }
}

extension HCert {
    private func parseBodyV1() -> [ParseError] {
        guard let schema = JSON(parseJSON: euDgcSchemaV1).dictionaryObject,
            let bodyDict = body.dictionaryObject else {
            return [.json(error: "Schema Validation failed")]
        }
        do {
            var bodyErrors = [ParseError]()
            let validation = try validate(bodyDict, schema: schema)
            validation.errors?.forEach { bodyErrors.append(.json(error: $0.description)) }
            
            #if DEBUG
            if CoreManager.config.debugPrintJsonErrors {
                 validation.errors?.forEach { print($0.description) }
            }
            #endif
            return bodyErrors
        } catch {
            return  [.json(error: "Body Validation failed")]
        }
    }
}

// MARK: - Hashes for revocation search
extension HCert {
    public var uvciHash: Data? {
        if statement?.uvci != nil,
           let uvciData = uvci.data(using: .utf8) {
           let data = SHA256.sha256(data: uvciData)
           //return data.dropLast(16)
            return data
        } else {
            return nil
        }
    }

    public var countryCodeUvciHash: Data? {
        if statement?.uvci != nil, let countryCodeUvciData = (issCode + uvci).data(using: .utf8) {
            let data = SHA256.sha256(data: countryCodeUvciData)
            return data
        } else {
            return nil
        }
    }

    public var signatureHash: Data? {
        guard var signatureBytesToHash = CBOR.unwrap(data: cborData)?.signatureBytes else { return nil }
          
        if isECDSASigned {
            signatureBytesToHash = Array(signatureBytesToHash.prefix(32))
        }
        let data = SHA256.sha256(data: Data(signatureBytesToHash))
        return data
    }

    private var isECDSASigned: Bool {
        guard let cborHeader = CBOR.header(from: cborData), let algorithmField = cborHeader[1] else { return false }
        
        let coseES256Algorithm = -7
        return algorithmField == SwiftCBOR.CBOR(integerLiteral: coseES256Algorithm)
    }
}

public extension HCert {
    func lookUp(mode: RevocationMode, hash: Data) -> CertLookUp {
        switch mode {
        case .point:
            return CertLookUp(kid: kidStr, section: hash.hexString[0], x: "null", y: "null")
        case .vector:
            return CertLookUp(kid: kidStr, section: hash.hexString[1], x: payloadString[0], y: "null")
        case .coordinate:
            return CertLookUp(kid: kidStr, section: hash.hexString[2], x: payloadString[0], y: payloadString[1])
        }
    }
}
