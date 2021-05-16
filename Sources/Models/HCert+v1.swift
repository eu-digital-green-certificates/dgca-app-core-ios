//
//  File.swift
//  
//
//  Created by Yannick Spreen on 5/16/21.
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
