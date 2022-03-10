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

public struct ValidityState {
    public static var validState = ValidityState()
    public static var invalidState = ValidityState(isValid: false)
    public static var revocatedState = ValidityState(isRevocated: true)

    public let technicalValidity: HCertValidity
    public var issuerValidity: HCertValidity
    public var destinationValidity: HCertValidity
    public var travalerValidity: HCertValidity
    public var allRulesValidity: HCertValidity
    public var revocationValidity: HCertValidity
    
    public let validityFailures: [String]
    public var infoRulesSection: InfoSection?

    public var isNotPassed: Bool {
        return technicalValidity != .valid ||
            issuerInvalidation != .passed || destinationAcceptence != .passed || travalerAcceptence != .passed
    }
    
    public init(isValid: Bool = true) {
        self.technicalValidity = isValid ? .valid : .invalid
        self.issuerValidity = isValid ? .valid : .invalid
        self.destinationValidity = isValid ? .valid : .invalid
        self.travalerValidity = isValid ? .valid : .invalid
        self.allRulesValidity = isValid ? .valid : .invalid
        self.revocationValidity = isValid ? .valid : .invalid
        self.validityFailures = []
        self.infoRulesSection = nil
    }
 
    public init(isRevocated: Bool) {
        self.technicalValidity = .revocated
        self.issuerValidity = .revocated
        self.destinationValidity = .revocated
        self.travalerValidity = .revocated
        self.allRulesValidity = .revocated
        self.revocationValidity = .revocated
        self.validityFailures = []
        self.infoRulesSection = nil
    }

    public init(
        technicalValidity: HCertValidity,
        issuerValidity: HCertValidity,
        destinationValidity: HCertValidity,
        travalerValidity: HCertValidity,
        allRulesValidity: HCertValidity,
        revocationValidity: HCertValidity,
        validityFailures: [String],
        infoRulesSection: InfoSection?) {
            self.technicalValidity = technicalValidity
            self.issuerValidity = issuerValidity
            self.destinationValidity = destinationValidity
            self.travalerValidity = travalerValidity
            self.revocationValidity = revocationValidity
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
                ruleResult = .failed
            case .ruleInvalid:
                ruleResult = .open
            case .revocated:
                ruleResult = .failed
         }
        return ruleResult
    }
    
    public var destinationAcceptence: RuleValidationResult {
        let ruleResult: RuleValidationResult
        switch destinationValidity {
            case .valid:
                ruleResult = .passed
            case .invalid:
                ruleResult = .failed
            case .ruleInvalid:
                ruleResult = .open
            case .revocated:
                ruleResult = .failed
        }
        return ruleResult
    }
    
    public var travalerAcceptence: RuleValidationResult {
        let ruleResult: RuleValidationResult
        switch travalerValidity {
            case .valid:
                ruleResult = .passed
            case .invalid:
                ruleResult = .failed
            case .ruleInvalid:
                ruleResult = .open
            case .revocated:
                ruleResult = .failed
        }
        return ruleResult
    }
}
