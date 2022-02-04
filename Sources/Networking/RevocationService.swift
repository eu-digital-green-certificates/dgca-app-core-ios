//
//  RevocationService.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 21.01.2022.
//

import UIKit


public enum RevocationError: Error {
    case unauthorized // TODO - add  unauthorized(error: NSError?)
    case invalidID
    case failedLoading(reason: String)
    case network(reason: String)
}

public typealias RevocationListCompletion = ([RevocationModel]?, String?, RevocationError?) -> Void
public typealias PartitionListCompletion = ([PartitionModel]?, String?, RevocationError?) -> Void
public typealias HashDataCompletion = (Data?, String?, RevocationError?) -> Void

internal typealias DataTaskCompletion<T: Codable> = (T?, String?, RevocationError?) -> Void

public final class RevocationService {

    static let shared = RevocationService()
    
    lazy var session: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    public func loadAllRevocations(completion: @escaping RevocationListCompletion) {
        let path = ServiceConfig.baseServerPath + ServiceConfig.allRevocations.rawValue
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    
    public func loadPartitions(forKid kidValue: String, completion: @escaping PartitionListCompletion) {
        let partitionComponent = String(format: ServiceConfig.kidPartitions.rawValue, kidValue)
        let path = ServiceConfig.baseServerPath + partitionComponent
        
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    
    public func loadPartitions(forKid kidValue: String, pid pidValue: String, completion: @escaping PartitionListCompletion) {
        let partitionComponent = String(format: ServiceConfig.partitionsWithID.rawValue, kidValue, pidValue)
        let path = ServiceConfig.baseServerPath + partitionComponent
        
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }

    
    public func loadChunks(forKid kidValue: String, pid pidValue: String, cids: [String], completion: @escaping HashDataCompletion) {
        let partitionComponent = String(format: ServiceConfig.partitionChanks.rawValue, kidValue, pidValue)
        let path = ServiceConfig.baseServerPath + partitionComponent
        
        let postData = try? JSONEncoder().encode(cids)
        guard let request = RequestFactory.servicePostRequest(path: path, body: postData) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }

    
    public func loadChunk(forKid kidValue: String, pid pidValue: String, cid cidValue: String, completion: @escaping HashDataCompletion) {
        let partitionComponent = String(format: ServiceConfig.chunkIDPath.rawValue, kidValue, pidValue, cidValue)
        let path = ServiceConfig.baseServerPath + partitionComponent
        
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    
    public func loadSlices(forKid kidValue: String, pid pidValue: String, cid cidValue: String, slices: [String],
            completion: @escaping HashDataCompletion) {
        let partitionComponent = String(format: ServiceConfig.slicesPath.rawValue, kidValue, pidValue, cidValue)
        let path = ServiceConfig.baseServerPath + partitionComponent
        
        let postData = try? JSONEncoder().encode(slices)
        guard let request = RequestFactory.servicePostRequest(path: path, body: postData) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }

    
    public func loadSlice(forKid kidValue: String, pid pidValue: String, cid cidValue: String, slice sidValue: [String],
            completion: @escaping HashDataCompletion) {
        let partitionComponent = String(format: ServiceConfig.sliceWithIDPath.rawValue, kidValue, pidValue, cidValue, sidValue)
        let path = ServiceConfig.baseServerPath + partitionComponent
        
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    
    // private methods
    fileprivate func startDataTask<T: Codable>(for request: URLRequest, completion: @escaping DataTaskCompletion<T>) {
        let dataTask = session.dataTask(with: request) {[unowned self] (data, response, error) in
            guard error == nil,
                let httpResponse = response as? HTTPURLResponse,
                  self.defaultResponseValidation(statusCode: httpResponse.statusCode) == nil,

                let data = data else {
                    completion(nil, nil, RevocationError.network(reason: error!.localizedDescription))
                    return
            }
            do {
                var eTag: String = ""
                let decodedData: T = try JSONDecoder().decode(T.self, from: data)
                 if let eTagValue = httpResponse.allHeaderFields["eTag"] as? String {
                     eTag = eTagValue
                 }
                completion(decodedData, eTag, nil)

            } catch {
                completion(nil, nil, RevocationError.failedLoading(reason: "Revocation list parsing error"))
            }
        }
        dataTask.resume()
    }
    
    
    fileprivate func defaultResponseValidation(statusCode: Int) -> RevocationError? {
        switch statusCode {
        case 200:
            return nil
        case 304:
            return RevocationError.network(reason: "Not-Modified.")
        case 400, 404:
            return RevocationError.invalidID
        case 401:
            return RevocationError.unauthorized
        case 412:
            return RevocationError.network(reason: "Pre-Condition Failed.")
        default:
            return RevocationError.network(reason: "Failed with statusCode \(statusCode)")
        }
    }
}
