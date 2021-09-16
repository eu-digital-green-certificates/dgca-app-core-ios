//
//  File.swift
//  
//
//  Created by Alexandr Chernyy on 17.06.2021.
//

import Foundation

public class CountryModel: Codable {
  public var code: String
  public var debugModeEnabled: Bool

  public var name: String {
    get { l10n("country.\(code.uppercased())")}
  }

  public init(code: String, debugModeEnabled: Bool = false) {
    self.code = code
    self.debugModeEnabled = debugModeEnabled
  }
  
  enum CodingKeys: String, CodingKey {
    case code = "code", debugModeEnabled
  }
  
  // Init Rule from JSON Data
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decode(String.self, forKey: .code)
    debugModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .debugModeEnabled) ?? false
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(code, forKey: .code)
    try container.encode(debugModeEnabled, forKey: .debugModeEnabled)
  }
}
