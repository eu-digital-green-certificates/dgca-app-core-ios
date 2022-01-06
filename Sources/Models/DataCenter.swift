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
//  DataCenter.swift
//  DGCAVerifier
//  
//  Created by Igor Khomiak on 03.11.2021.
//  
        
import Foundation
import CertLogic

public class DataCenter {
  static let shared = DataCenter()
  public static var appVersion: String {
    let versionValue = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?.?.?"
    let buildNumValue = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?.?.?"
    return "\(versionValue)(\(buildNumValue))"
  }


  public static let localDataManager: LocalDataManager = LocalDataManager()
  
  // MARK: - local data accessors
  
  public static var lastFetch: Date {
    return localDataManager.localData.lastFetch
  }
  
  public static var lastLaunchedAppVersion: String {
    return DataCenter.localDataManager.localData.lastLaunchedAppVersion
  }
  
  public static var certStrings: [DatedCertString] {
    return localDataManager.localData.certStrings
  }
}
