//
//  RequestFactory.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 20.01.2022.
//

import UIKit

internal enum ServiceConfig: String {
    case test = "/"
    case allRevocations = "/lists"
    case kidPartitions = "/%@/partitions"
    case partitionsWithID =  "/%@/partitions/%@"
    case partitionChanks = "/%@/partitions/%@/chunks"
    case chunkIDPath = "/%@/partitions/%@/chunks/%@"
    case slicesPath = "/%@/partitions/%@/chunks/%@/slice"
    case sliceWithIDPath = " /%@/partitions/%@/chunks/%@/slice/%@"
}

internal class RequestFactory {
    typealias StringDictionary = [String : String]

    // MARK: - Private methods
    fileprivate static func postRequest(url: URL, HTTPBody body: Data?, headerFields: StringDictionary?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        headerFields?.forEach { request.setValue($0.1, forHTTPHeaderField: $0.0) }
        return request
    }
    
    fileprivate static func request(url: URL, query: StringDictionary?, headerFields: StringDictionary?) -> URLRequest {
        var resultURL: URL = url
        if let query = query {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = query.map { URLQueryItem(name:$0.0, value: $0.1) }
            components?.queryItems = queryItems
            if let urlComponents = components?.url {
                resultURL = urlComponents
            }
        }
        
        var request = URLRequest(url: resultURL)
        request.httpMethod = "GET"
        
        headerFields?.forEach {
            request.setValue($0.1, forHTTPHeaderField: $0.0)
        }
        return request
    }
}

// TODO add protocol
extension RequestFactory {
    
    static func serviceGetRequest(path: String) -> URLRequest? {
        guard let url = URL(string: path) else { return nil }
        
        let result = request(url: url, query: nil, headerFields: ["Content-Type" : "application/json"])
        return result
    }

    static func servicePostRequest(path: String, body: Data?) -> URLRequest? {
        guard let url = URL(string: path) else { return nil }
        
        let result = postRequest(url: url, HTTPBody: body, headerFields: ["Content-Type" : "application/json"])
        return result
    }
}
