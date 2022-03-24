//
/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
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
//  SecureStorage.swift
//
//  
//  Created by Yannick Spreen on 4/25/21.
//  

import Foundation

public enum DataOperationError: Error {
  case noInputData
  case initializationError
  case encodindFailure
  case signingFailure
  case dataError(description: String)
}

public enum DataOperationResult {
  case success(Bool)
  case failure(Error)
}

public typealias DataCompletionHandler = (DataOperationResult) -> Void

struct SecureDB: Codable {
  let data: Data
  let signature: Data
}

public class SecureStorage<T: Codable> {
  
  lazy var databaseURL: URL = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let urlPath = URL(fileURLWithPath: documentsDirectory)
    let prodURL = urlPath.appendingPathComponent("\(fileName).db")
    return prodURL
  }()
  
  let fileName: String
  lazy var secureStorageKey = Enclave.loadOrGenerateKey(with: "secureStorageKey")

  public init(fileName: String) {
    self.fileName = fileName
  }

  /**
   Loads encrypted db and overrides it with an empty one if that fails.
   */
  public func loadOverride(fallback: T, completion: @escaping ((T?) -> Void)) {
    if !FileManager.default.fileExists(atPath: databaseURL.path) {
      self.save(fallback) { _ in
        self.load(completion: completion)
      }
    } else {
      self.load(completion: completion)
    }
  }

  public func loadStoredData(fallback: T, completion: @escaping ((T?) -> Void)) {
    if !FileManager.default.fileExists(atPath: databaseURL.path) {
      self.save(fallback) { _ in
        self.load(completion: completion)
      }

    } else {
      self.load(completion: completion)
    }
  }

  public func load(completion: @escaping ((T?) -> Void)) {
    guard let (data, signature) = read(),
      let key = secureStorageKey,
      Enclave.verify(data: data, signature: signature, with: key).0
    else {
      completion(nil)
      return
    }
    Enclave.decrypt(data: data, with: key) { decrypted, err in
      guard let decrypted = decrypted, err == nil,
        let data = try? JSONDecoder().decode(T.self, from: decrypted)
      else {
        completion(nil)
        return
      }
      completion(data)
    }
  }

  public func save(_ instance: T, completion: @escaping DataCompletionHandler) {
    guard let data = try? JSONEncoder().encode(instance),
      let key = secureStorageKey,
      let encrypted = Enclave.encrypt(data: data, with: key).0
    else {
      completion(.failure(DataOperationError.encodindFailure))
      return
    }
    Enclave.sign(data: encrypted, with: key, completion: { [unowned self] result, error in
      guard let signature = result, error == nil else {
        completion(.failure(DataOperationError.dataError(description: error!)))
        return
      }
      self.write(data: encrypted, signature: signature, completion: completion)
    })
  }

  func write(data: Data, signature: Data, completion: DataCompletionHandler) {
    do {
      let rawData = try JSONEncoder().encode(SecureDB(data: data, signature: signature))
      try rawData.write(to: databaseURL)
      completion(.success(true))
    } catch {
      completion(.failure(DataOperationError.encodindFailure))
      return
    }
  }

  func read() -> (Data, Data)? {
    guard let rawData = try? Data(contentsOf: databaseURL, options: [.uncached]),
      let result = try? JSONDecoder().decode(SecureDB.self, from: rawData)
    else { return nil }
    return (result.data, result.signature)
  }
}
