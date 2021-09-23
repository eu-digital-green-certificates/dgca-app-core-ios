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

public struct TicketingQR : Codable {
  public var protocolName    : String
  public var protocolVersion : String
  public var serviceIdentity : String
  public var token           : String
  public var consent         : String
  public var subject         : String
  public var serviceProvider : String
  
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

public struct ValidationService : Codable {
  public var id                 : String
  public var type               : String
  public var name               : String
  public var serviceEndpoint    : String
  public var isSelected         : Bool = false
}
