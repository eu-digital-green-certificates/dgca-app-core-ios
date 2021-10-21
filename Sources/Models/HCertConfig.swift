//
//  File.swift
//  
//
//  Created by Igor Khomiak on 20.10.2021.
//

import Foundation

public class HCertConfig {
  public static let supportedPrefixes = [ "HC1:" ]

  public let prefetchAllCodes: Bool
  public let checkSignatures: Bool
  public let debugPrintJsonErrors: Bool

  public init() {
    self.prefetchAllCodes = false
    self.checkSignatures = true
    self.debugPrintJsonErrors = true
  }
  
  public init(prefetchAllCodes: Bool, checkSignatures: Bool, debugPrintJsonErrors: Bool) {
    self.prefetchAllCodes = prefetchAllCodes
    self.checkSignatures = checkSignatures
    self.debugPrintJsonErrors = debugPrintJsonErrors
  }

  public static func checkCH1PreffixExist(_ payloadString: String?) -> Bool {
    guard let payloadString = payloadString  else { return false }
    
    for prfix in supportedPrefixes {
      if payloadString.starts(with: prfix) {
        return true
      }
    }
    return false
  }
  
  public static func parsePrefix(_ payloadString: String) -> String {
    for prfix in supportedPrefixes {
      if payloadString.starts(with: prfix) {
        return String(payloadString.dropFirst(prfix.count))
      }
    }
    return payloadString
  }

}
