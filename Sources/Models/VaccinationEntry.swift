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
//  TestResult.swift
//
//  
//  Created by Yannick Spreen on 4/28/21.
//  

import Foundation
import SwiftyJSON

struct VaccinationEntry: HCertEntry {
  var typeAddon: String {
    let format = l10n("vaccine.x-of-x")
    return .localizedStringWithFormat(format, doseNumber, dosesTotal)
  }

  var info: [InfoSection] {
    [
      InfoSection(
        header: l10n("vaccine.date"),
        content: date.localDateString
      ),
      InfoSection(
        header: l10n("vaccine.disease"),
        content: l10n("disease." + diseaseTargeted, or: "\(l10n("disease.unknown")): \(diseaseTargeted)")
      ),
      InfoSection(
        header: l10n("vaccine.manufacturer"),
        content: l10n("vac.man." + manufacturer, or: "\(l10n("vac.man.unknown")): \(manufacturer)"),
        isPrivate: true
      ),
      InfoSection(
        header: l10n("vaccine.product"),
        content: l10n("vac.product." + medicalProduct, or: "\(l10n("vac.product.unknown")): \(medicalProduct)"),
        isPrivate: true
      ),
      InfoSection(
        header: l10n("vaccine.type"),
        content: l10n("vac.type." + vaccineOrProphylaxis, or: "\(l10n("vac.type.unknown")): \(vaccineOrProphylaxis)"),
        isPrivate: true
      ),
      InfoSection(
        header: l10n("vaccine.country"),
        content: country(for: countryCode),
        isPrivate: true
      ),
      InfoSection(
        header: l10n("vaccine.issuer"),
        content: issuer,
        isPrivate: true
      )
    ]
  }

  var validityFailures: [String] {
    var fail = [String]()
    if date > HCert.clock {
      fail.append(l10n("hcert.err.vac.future"))
    }
    return fail
  }

  enum Fields: String {
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

  var diseaseTargeted: String
  var vaccineOrProphylaxis: String
  var medicalProduct: String
  var manufacturer: String
  var countryCode: String
  var issuer: String
  var uvci: String
  var doseNumber: Int
  var dosesTotal: Int
  var date: Date
}
