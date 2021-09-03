//
//  File.swift
//  
//
//  Created by Alexandr Chernyy on 17.06.2021.
//

import Foundation

public class CountryModel: Codable {
  public var code: String
  public var debugModeEnabled = false

  public var name: String {
    get { l10n("country.\(code.uppercased())")}
  }

  public init(code: String) {
    self.code = code
  }
  
  enum CodingKeys: String, CodingKey {
    case code = "code"
  }

}
