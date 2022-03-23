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
        

public struct ValidityState {

    public let technicalValidity: HCertValidity
    public let issuerValidity: HCertValidity
    public let destinationValidity: HCertValidity
    public let travalerValidity: HCertValidity
    public let allRulesValidity: HCertValidity
    public let revocationValidity: HCertValidity
    public let validityFailures: [String]
    public let infoRulesSection: InfoSection?

    public var isNotPassed: Bool {
        return technicalValidity != .valid ||
            issuerValidity != .valid ||
            destinationValidity != .valid ||
            revocationValidity != .valid ||
            travalerValidity != .valid
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
}
