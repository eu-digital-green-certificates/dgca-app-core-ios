//
//  File.swift
//  
//
//  Created by Igor Khomiak on 15.10.2021.
//

import Foundation
import SwiftyJSON

public struct InfoSection {
  public var header: String
  public var content: String
  public var style = InfoSectionStyle.normal
  public var isPrivate = false
  public var sectionItems: [InfoSection] = []
  public var isExpanded: Bool = false
  public var countryName: String?
  public var ruleValidationResult: RuleValidationResult = .open
  
  public init(header: String, content: String, style: InfoSectionStyle = .normal,
        isPrivate: Bool = false,  countryName: String? = nil, ruleValidationResult: RuleValidationResult = .open) {
    self.header = header
    self.content = content
    self.countryName = countryName
    self.style = style
    self.isPrivate = isPrivate
    self.ruleValidationResult = ruleValidationResult
  }
}
