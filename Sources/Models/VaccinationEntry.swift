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
//  VaccinationEntry.swift
//
//  Created by Yannick Spreen on 4/28/21.
//  

import Foundation
import SwiftyJSON

public struct VaccinationEntry: HCertEntry {
    
  public var typeAddon: String {
    let format = l10n("%d of %d")
    return .localizedStringWithFormat(format, doseNumber, dosesTotal)
  }
  public let uvci: String
    
  private let diseaseTargeted: String
  private let vaccineOrProphylaxis: String
  private let medicalProduct: String
  private let manufacturer: String
  private let countryCode: String
  private let issuer: String
  private let doseNumber: Int
  private let dosesTotal: Int
  private let date: Date

  public var info: [InfoSection] {
    let strContent = String(format: l10n("%@ or %@: %@"), l10n("disease." + diseaseTargeted), l10n("Unknown"), "\(diseaseTargeted)")

    return [InfoSection(header: l10n("Date of Vaccination"), content: date.localDateString),
      InfoSection( header: l10n("Targeted Disease"), content: strContent),
      InfoSection(header: l10n("Authorization Holder / Manufacturer"),
        content: l10n("vac.man." + manufacturer, or: "\(l10n("Unknown")): \(manufacturer)"), isPrivate: true ),
      InfoSection(header: l10n("Medical Product"),
        content: l10n("vac.product." + medicalProduct, or: "\(l10n("Unknown")): \(medicalProduct)"), isPrivate: true
      ),
      InfoSection(header: l10n("Vaccine or Prophylaxis"),
        content: l10n("vac.type." + vaccineOrProphylaxis, or: "\(l10n("Unknown")): \(vaccineOrProphylaxis)"),
        isPrivate: true),
      InfoSection( header: l10n("Country of Vaccination"), content: country(for: countryCode), isPrivate: true),
      InfoSection( header: l10n("Certificate Issuer"), content: issuer, isPrivate: true)
    ]
  }
  
  public var walletInfo: [InfoSection] {
    let strContent = String(format: l10n("%@ or %@: %@"), l10n("disease." + diseaseTargeted), l10n("Unknown"), "\(diseaseTargeted)")

    return [InfoSection( header: l10n("Date of Vaccination"), content: date.localDateString ),
      InfoSection( header: l10n("Targeted Disease"), content: strContent),
      InfoSection( header: l10n("Authorization Holder / Manufacturer"),
        content: l10n("vac.man." + manufacturer, or: "\(l10n("Unknown")): \(manufacturer)"), isPrivate: true ),
      InfoSection(header: l10n("Vaccine or Prophylaxis"),
        content: l10n("vac.type." + vaccineOrProphylaxis, or: "\(l10n("Unknown")): \(vaccineOrProphylaxis)"), isPrivate: true),
      InfoSection( header: l10n("Country of Vaccination"), content: country(for: countryCode), isPrivate: true),
      InfoSection(header: l10n("Certificate Issuer"), content: issuer, isPrivate: true)]
  }

    public var validityFailures: [String] {
    var fail = [String]()
    if date > HCert.clock {
      fail.append(l10n("Vaccination date is in the future."))
    }
    return fail
  }

  private enum Fields: String {
    case diseaseTargeted = "tg"
    case vaccineOrProphylaxis = "vp"
    case medicalProduct = "mp"
    case manufacturer = "ma"
    case doseNumber = "dn"
    case dosesTotal = "sd"
    case date = "dt"
    case countryCode = "co"
    case issuer = "is"
    case uvci = "ci"
  }

  init?(body: JSON) {
    guard
      let diseaseTargeted = body[Fields.diseaseTargeted.rawValue].string,
      let vaccineOrProphylaxis = body[Fields.vaccineOrProphylaxis.rawValue].string,
      let medicalProduct = body[Fields.medicalProduct.rawValue].string,
      let manufacturer = body[Fields.manufacturer.rawValue].string,
      let country = body[Fields.countryCode.rawValue].string,
      let issuer = body[Fields.issuer.rawValue].string,
      let uvci = body[Fields.uvci.rawValue].string,
      let doseNumber = body[Fields.doseNumber.rawValue].int,
      let dosesTotal = body[Fields.dosesTotal.rawValue].int,
      let dateStr = body[Fields.date.rawValue].string,
      let date = Date(dateString: dateStr)
    else {
      return nil
    }
    self.diseaseTargeted = diseaseTargeted
    self.vaccineOrProphylaxis = vaccineOrProphylaxis
    self.medicalProduct = medicalProduct
    self.manufacturer = manufacturer
    self.countryCode = country
    self.issuer = issuer
    self.uvci = uvci
    self.doseNumber = doseNumber
    self.dosesTotal = dosesTotal
    self.date = date
  }
}
