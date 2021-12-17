//
/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-wallet-app-ios
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
//  TicketingData.swift
//  DGCAWallet
//  
//  Created by Illia Vlasov on 20.09.2021.
//  


import Foundation

public struct CheckInQR : Codable {
  public let protocolName    : String
  public let protocolVersion : String
  public let serviceIdentity : String
  public let token           : String
  public let consent         : String
  public let subject         : String
  public let serviceProvider : String
  
  private enum CodingKeys: String, CodingKey {
    case protocolName = "protocol"
    case protocolVersion
    case serviceIdentity
    case token
    case consent
    case subject
    case serviceProvider
  }
}

public struct ServerListResponse : Codable {
  public let id                  : String?
  public let service             : [ValidationService]?
  public let verificationMethod  : [VerificationMethod]?
}


public struct PublicKeyJWK : Codable {
  public let kid : String
  public let alg : String
  public let x5c : [String]
  public let use : String
}

public struct VerificationMethod : Codable {
  public let id           : String
  public let controller   : String
  public let type         : String
  public let publicKeyJwk : PublicKeyJWK?
  public let verificationMethods : [String]?
}

public struct ValidationService : Codable {
  public let id               : String
  public let type             : String
  public let name             : String
  public let serviceEndpoint  : String
  public var isSelected       : Bool? = false
}
