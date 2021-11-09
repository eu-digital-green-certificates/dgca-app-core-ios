//
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
//  ValidityState.swift
//  DGCAVerifier
//  
//  Created by Igor Khomiak on 18.10.2021.
//  
        

import Foundation
import SwiftyJSON

public struct ValidityState {
    public static var invalid = ValidityState()
    
    public let technicalValidity: HCertValidity
    public let issuerValidity: HCertValidity
    public let destinationValidity: HCertValidity
    public let travalerValidity: HCertValidity
    public let allRulesValidity: HCertValidity
    public let validityFailures: [String]
    public var infoRulesSection: InfoSection?
    
    public init() {
        self.technicalValidity = .invalid
        self.issuerValidity = .invalid
        self.destinationValidity = .invalid
        self.travalerValidity = .invalid
        self.allRulesValidity = .invalid
        self.validityFailures = []
        self.infoRulesSection = nil
    }
    
    public init(
        technicalValidity: HCertValidity,
        issuerValidity: HCertValidity,
        destinationValidity: HCertValidity,
        travalerValidity: HCertValidity,
        allRulesValidity: HCertValidity,
        validityFailures: [String],
        infoRulesSection: InfoSection?) {
            self.technicalValidity = technicalValidity
            self.issuerValidity = issuerValidity
            self.destinationValidity = destinationValidity
            self.travalerValidity = travalerValidity
            self.allRulesValidity = allRulesValidity
            self.validityFailures = validityFailures
            self.infoRulesSection = infoRulesSection
    }
    
    private var validity: HCertValidity {
      return validityFailures.isEmpty ? .valid : .invalid
    }
    
    public var isValid: Bool {
      return validityFailures.isEmpty
    }

    public var issuerInvalidation: RuleValidationResult {
        let ruleResult: RuleValidationResult
        switch issuerValidity {
          case .valid:
            ruleResult = .passed
          case .invalid:
            ruleResult = .error
          case .ruleInvalid:
            ruleResult = .open
        }
        return ruleResult
    }
    
    public var destinationAcceptence: RuleValidationResult {
        let ruleResult: RuleValidationResult
        switch destinationValidity {
          case .valid:
            ruleResult = .passed
          case .invalid:
            ruleResult = .error
          case .ruleInvalid:
            ruleResult = .open
        }
        return ruleResult
    }
    
    public var travalerAcceptence: RuleValidationResult {
        let ruleResult: RuleValidationResult
        switch travalerValidity {
          case .valid:
            ruleResult = .passed
          case .invalid:
            ruleResult = .error
          case .ruleInvalid:
            ruleResult = .open
        }
        return ruleResult
    }
}
