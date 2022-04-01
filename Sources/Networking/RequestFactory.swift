//
//  RequestFactory.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 20.01.2022.
//

import Foundation

internal enum ServiceConfig: String {
    case test = "/"
    case linkForAllRevocations = "/lists"
    case linkForPartitions = "/lists/%@/partitions"
    case linkForPartitionsWithID =  "/lists/%@/partitions/%@"
    case linkForPartitionChunks = "/lists/%@/partitions/%@/slices"
    case linkForChunkSlices = "/lists/%@/partitions/%@/chunks/%@/slices"
    case linkForSingleSlice = "/lists/%@/partitions/%@/chunks/%@/slices/%@"
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

extension RequestFactory {
    
    static func serviceGetRequest(path: String, etag: String? = nil, dateStr: String? = nil) -> URLRequest? {
        guard let url = URL(string: path) else { return nil }
        var headerDict: [String : String] = ["Content-Type" : "application/json"]
        if etag == nil {
            headerDict["If-None-Match"] = ""
        } else {
            headerDict["If-Match"] = etag!
            headerDict["X-SLICE-FILTER-TYPE"] = sliceType.rawValue
        }
        if dateStr  != nil {
            headerDict["If-Modified-Since"] = dateStr!
        }
        
        let result = request(url: url, query: nil, headerFields: headerDict)
        return result
    }
    
    static func servicePostRequest(path: String, body: Data?, etag: String? = nil, dateStr: String? = nil) -> URLRequest? {
        guard let url = URL(string: path) else { return nil }
        
        var headerDict: [String : String] = ["Content-Type" : "application/json"]
        if etag == nil {
            headerDict["If-None-Match"] = ""
        } else {
            headerDict["If-Match"] = etag!
            headerDict["X-SLICE-FILTER-TYPE"] = sliceType.rawValue
        }
        if dateStr  != nil {
            headerDict["If-Modified-Since"] = dateStr!
        }

        let result = postRequest(url: url, HTTPBody: body, headerFields: headerDict)
        return result
    }
}
