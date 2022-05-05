/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-verifier-app-ios
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
//  InfoSection.swift
//  
//
//  Created by Igor Khomiak on 15.10.2021.
//

import Foundation

public class InfoSection {
  public let header: String
  public let content: String
  public let style: InfoSectionStyle
  public let isPrivate: Bool
  public var sectionItems: [InfoSection] = []
  public var isExpanded: Bool = false
  public var countryName: String?
  public let ruleValidationResult: HCertValidity
  
  public init(header: String, content: String, style: InfoSectionStyle = .normal,
        isPrivate: Bool = false,  countryName: String? = nil, ruleValidationResult: HCertValidity = .ruleInvalid) {
    self.header = header
    self.content = content
    self.countryName = countryName
    self.style = style
    self.isPrivate = isPrivate
    self.ruleValidationResult = ruleValidationResult
  }
}
