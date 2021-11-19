//
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
//  TestEntry.swift
//
//  
//  Created by Yannick Spreen on 4/28/21.
//  

import Foundation
import SwiftyJSON

enum TestResult: String {
  case detected = "260373001"
  case notDetected = "260415000"
}

public struct TestEntry: HCertEntry {
    public var typeAddon: String { "" }
    public let uvci: String

    private let diseaseTargeted: String
    private let type: String
    private let sampleTime: Date
    private let resultNegative: Bool
    private let testCenter: String
    private let countryCode: String
    private let issuer: String

    public var info: [InfoSection] {
      return [InfoSection( header: l10n("Time of Sampling"), content: sampleTime.dateTimeStringUtc),
      InfoSection( header: l10n("Test Result"), content: resultNegative ? l10n("Not Detected") : l10n("Detected ⚠️")),
      InfoSection( header: l10n("Targeted Disease"), content: l10n("disease." + diseaseTargeted, or: "\(l10n("disease.unknown")): \(diseaseTargeted)")),
      InfoSection( header: l10n("Test Center"), content: testCenter, isPrivate: true),
      InfoSection( header: l10n("Country of Test"), content: country(for: countryCode), isPrivate: true),
      InfoSection( header: l10n("Test Issuer"), content: issuer, isPrivate: true )]
  }

    public var walletInfo: [InfoSection] {
      return [InfoSection( header: l10n("Test Result"), content: resultNegative ? l10n("Not Detected") : l10n("Detected ⚠️")),
      InfoSection( header: l10n("Time of Sampling"), content: sampleTime.dateTimeStringUtc),
      InfoSection( header: l10n("Type of Test"), content: type),
      InfoSection( header: l10n("Targeted Disease"), content: l10n("disease." + diseaseTargeted, or: "\(l10n("disease.unknown")): \(diseaseTargeted)")),
      InfoSection( header: l10n("Test Center"), content: testCenter, isPrivate: true),
      InfoSection( header: l10n("Country of Test"),content: country(for: countryCode), isPrivate: true),
      InfoSection( header: l10n("Test Issuer"),content: issuer, isPrivate: true)
    ]
  }

  public var validityFailures: [String] {
      var fail = [String]()
      if !resultNegative {
        fail.append(l10n("The test result is positive."))
      }
      if sampleTime > HCert.clock {
        fail.append(l10n("Test date is in the future."))
      }
      return fail
  }

  enum Fields: String {
    case diseaseTargeted = "tg"
    case type = "tt"
    case sampleTime = "sc"
    case result = "tr"
    case testCenter = "tc"
    case countryCode = "co"
    case issuer = "is"
    case uvci = "ci"
  }

  init?(body: JSON) {
    guard
      let diseaseTargeted = body[Fields.diseaseTargeted.rawValue].string,
      let type = body[Fields.type.rawValue].string,
      let sampleTimeStr = body[Fields.sampleTime.rawValue].string,
      let sampleTime = Date(rfc3339DateTimeString: sampleTimeStr),
      let result = body[Fields.result.rawValue].string,
      let testCenter = body[Fields.testCenter.rawValue].string,
      let countryCode = body[Fields.countryCode.rawValue].string,
      let issuer = body[Fields.issuer.rawValue].string,
      let uvci = body[Fields.uvci.rawValue].string
    else {
      return nil
    }
    self.diseaseTargeted = diseaseTargeted
    self.type = type
    self.sampleTime = sampleTime
    self.resultNegative = (TestResult(rawValue: result) == .notDetected)
    self.testCenter = testCenter
    self.countryCode = countryCode
    self.issuer = issuer
    self.uvci = uvci
  }

}
