//
//  File.swift
//  
//
//  Created by Yannick Spreen on 5/3/21.
//

import Foundation

public protocol PublicKeyStorageDelegate {
  func getEncodedPublicKey(for _: String) -> String?
}
