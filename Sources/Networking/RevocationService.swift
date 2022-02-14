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
    
    var baseServiceURLPath: String
    var allChunks = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
    
    public init(baseServicePath path: String) {
        self.baseServiceURLPath = path
    }
    
    lazy var session: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    // MARK: - Revocation Lists
    // summary: Returns an overview about all available revocation lists.
    // description: This method returns an over about available revocation lists for each KID. The response contains for all available KIDs the last modification date, the used hash types etc.

    public func getRevocationLists(completion: @escaping RevocationListCompletion) {
        let path = baseServiceURLPath + ServiceConfig.linkForAllRevocations.rawValue
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    // MARK: - Partitions Lists
    // summary: Returns for the selected kid all Partitions
    // description: Returns a list of all available partitions.
    
    public func getRevocationPartitions(for kid: String, completion: @escaping PartitionListCompletion) {
        let partitionComponent = String(format: ServiceConfig.linkForPartitions.rawValue, kid)
        let path = baseServiceURLPath + partitionComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }

    // MARK: - Partitions Lists with ID
    // summary: Returns for the selected kid a Partition
    // description: Returns a Partition by Id
    
    public func getRevocationPartitions(for kid: String, id: String, completion: @escaping PartitionListCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForPartitionsWithID.rawValue, kid, id)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    // MARK: - All chunks Lists
    // summary: Returns for the selected partition all chunks.
    // description: Returns a Partition by Id
    
    public func getRevocationPartitionChunks(for kid: String, id: String, cids: [String]? = nil, completion: @escaping HashDataCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForPartitionChanks.rawValue, kid, id)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)

        let encoder = JSONEncoder()
        let postData = cids == nil ? try? encoder.encode(allChunks) : try? encoder.encode(cids!)
        
        guard let request = RequestFactory.servicePostRequest(path: path, body: postData, etag: eTag) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }
    
    // MARK: - Chunk all content Lists
    //summary: Returns for the selected chunk all content.
    //description: Returns a Partition by Id
    
    public func getRevocationPartitionChunk(for kid: String, id: String, cid: String, completion: @escaping HashDataCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForChankWithID.rawValue, kid, id, cid)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, nil, RevocationError.failedLoading(reason: "Bad request for path \(path)"))
            return
        }
        self.startDataTask(for: request, completion: completion)
    }

    // private methods
    fileprivate func startDataTask<T: Codable>(for request: URLRequest, completion: @escaping DataTaskCompletion<T>) {
        let dataTask = session.dataTask(with: request) {[unowned self] (data, response, error) in
            guard error == nil else {
                completion(nil, nil, RevocationError.network(reason: error!.localizedDescription))
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse,
                self.defaultResponseValidation(statusCode: httpResponse.statusCode) == nil else {
                completion(nil, nil, RevocationError.network(reason: "Response failed validation"))
                return
            }
            do {
                var eTag: String = ""
                let decodedData: T = try JSONDecoder().decode(T.self, from: data)
                 if let eTagString = httpResponse.allHeaderFields["Etag"] as? String {
                     let str = eTagString.replacingOccurrences(of: "\"", with: "")
                     eTag = str
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
