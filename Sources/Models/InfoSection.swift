//
//  File.swift
//  
//
//  Created by Igor Khomiak on 15.10.2021.
//

import Foundation
import SwiftyJSON

public class InfoSection {
  public let header: String
  public let content: String
  public let style: InfoSectionStyle
  public let isPrivate: Bool
  public var sectionItems: [InfoSection] = []
  public var isExpanded: Bool = false
  public var countryName: String?
  public let ruleValidationResult: RuleValidationResult
  
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
