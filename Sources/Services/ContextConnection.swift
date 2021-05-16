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
//  ContextConnection.swift
//
//
//  Created by Yannick Spreen on 5/12/21.
//

import Foundation
import SwiftyJSON
import Alamofire

public protocol ContextConnection {
  static var config: JSON { get }
}

var alamofireSessions = [String: Alamofire.Session]()

public extension ContextConnection {
  static func request(
    _ path: [String],
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    interceptor: RequestInterceptor? = nil,
    requestModifier: Alamofire.Session.RequestModifier? = nil
  ) -> DataRequest {
    var json = config
    for key in path {
      json = json[key]
    }
    let url = json["url"].string ?? ""
    if alamofireSessions[url] == nil {
      var keys = ["*"]
      if json["pubKeys"].exists() {
        keys = json["pubKeys"].array?.compactMap { $0.string } ?? []
      }
      let host = URL(string: url)?.host ?? ""
      let evaluators: [String: ServerTrustEvaluating] = [
        host: CompositeTrustEvaluator(evaluators: [
          RevocationTrustEvaluator(),
          CertEvaluator(pubKeys: keys)
        ])
      ]

      let trust = ServerTrustManager(evaluators: evaluators)
      alamofireSessions[url] = Alamofire.Session(serverTrustManager: trust)
    }
    let session = alamofireSessions[url] ?? AF
    return session.request(
      url,
      method: method,
      parameters: parameters,
      encoding: encoding,
      headers: headers,
      interceptor: interceptor,
      requestModifier: requestModifier
    )
  }
}
