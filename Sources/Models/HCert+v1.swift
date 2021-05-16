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
//  HCert+v1.swift
//
//
//  Created by Yannick Spreen on 4/19/21.
//

import Foundation
import SwiftyJSON
import JSONSchema

extension HCert {
  mutating func parseBodyV1(errors: ParseErrors? = nil) -> Bool {
    guard
      let schema = JSON(parseJSON: euDgcSchemaV1).dictionaryObject,
      let bodyDict = body.dictionaryObject
    else {
      errors?.errors.append(.json(error: "Validation failed"))
      return false
    }

    guard
      let validation = try? validate(bodyDict, schema: schema)
    else {
      errors?.errors.append(.json(error: "Validation failed"))
      return false
    }
    validation.errors?.forEach {
      errors?.errors.append(.json(error: $0.description))
    }
    #if DEBUG
    if Self.debugPrintJsonErrors {
      validation.errors?.forEach {
        print($0.description)
      }
    }
    #else
    if !validation.valid {
      return false
    }
    #endif
    return true
  }
}
