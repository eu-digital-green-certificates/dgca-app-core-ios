//
//  DatedCertString.swift
//  
//
//  Created by Denis Melenevsky on 22.12.2021.
//

import Foundation

public class DatedCertString: Codable {
  public var isSelected: Bool = false
  public let date: Date
  public let certString: String
  public let storedTAN: String?
  public var cert: HCert? {
    return try? HCert(from: certString)
  }


  init(date: Date, certString: String, storedTAN: String?) {
    self.date = date
    self.certString = certString
    self.storedTAN = storedTAN
  }
}
