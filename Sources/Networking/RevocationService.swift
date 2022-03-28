//
//  RevocationService.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 21.01.2022.
//

import Foundation


public enum RevocationError: Error {
    case unauthorized // TODO - add  unauthorized(error: NSError?)
    case invalidID
    case badRequest(path: String)
    case nodata
    case failedLoading(reason: String)
    case failedValidation(status: Int)
    case network(reason: String)
}

public typealias RevocationListCompletion = ([RevocationModel]?, String?, RevocationError?) -> Void
public typealias PartitionListCompletion = ([PartitionModel]?, String?, RevocationError?) -> Void
public typealias JSONDataTaskCompletion<T: Codable> = (T?, String?, RevocationError?) -> Void
public typealias ZIPDataTaskCompletion = (Data?, RevocationError?) -> Void

public final class RevocationService: RevocationServiceProtocol {
    
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
    // paths:  /lists:   (get)
    public func getRevocationLists(completion: @escaping RevocationListCompletion) {
        let path = baseServiceURLPath + ServiceConfig.linkForAllRevocations.rawValue
        guard let request = RequestFactory.serviceGetRequest(path: path) else {
            completion(nil, nil, .badRequest(path: path))
            return
        }
        self.startJSONDataTask(for: request, completion: completion)
    }
    
    // MARK: - Partitions Lists
    // summary: Returns for the selected kid all Partitions
    // description: Returns a list of all available partitions.
    // paths:  /lists/{kid}/partitions (get)
    
    public func getRevocationPartitions(for kid: String, completion: @escaping PartitionListCompletion) {
        let partitionComponent = String(format: ServiceConfig.linkForPartitions.rawValue, kid)
        let path = baseServiceURLPath + partitionComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, nil, .badRequest(path: path))
            return
        }
        self.startJSONDataTask(for: request, completion: completion)
    }

    // MARK: - Partitions Lists with ID
    // summary: Returns for the selected kid a Partition
    // description: Returns a Partition by Id
    // paths:  /lists/{kid}/partitions/{id}: (get)
    
    public func getRevocationPartitions(for kid: String, id: String, completion: @escaping PartitionListCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForPartitionsWithID.rawValue, kid, id)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, nil, .badRequest(path: path))
            return
        }
        self.startJSONDataTask(for: request, completion: completion)
    }
    
    // MARK: - All chunks Lists
    // summary: Returns for the selected partition all chunks.
    // description: Returns a Partition by Id
    // paths:  /lists/{kid}/partitions/{id}/chunks   (post)

    public func getRevocationPartitionChunks(for kid: String, id: String, cids: [String]? = nil, completion: @escaping ZIPDataTaskCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForPartitionChunks.rawValue, kid, id)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        
        let encoder = JSONEncoder()
        let postData = cids == nil ? try? encoder.encode(allChunks) : try? encoder.encode(cids!)
        
        guard let request = RequestFactory.servicePostRequest(path: path, body: postData, etag: eTag) else {
            completion(nil, .badRequest(path: path))
            return
        }
        self.startZIPDataTask(for: request, completion: completion)
    }
    
    // MARK: - Chunk all content
    //summary: Returns for the selected chunk all content.
    //description: Returns a Partition by Id
    // paths:  /lists/{kid}/partitions/{id}/chunks/{cid} (get)
    
    public func getRevocationPartitionChunk(for kid: String, id: String, cid: String, completion: @escaping ZIPDataTaskCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForChunkSlices.rawValue, kid, id, cid)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, .badRequest(path: path))
            return
        }
        self.startZIPDataTask(for: request, completion: completion)
    }
    
    // MARK: - Chunk's all slices Lists
    // summary: Returns for the selected partition all chunks.
    // description: Returns a Partition by Id
    // paths:  /lists/{kid}/partitions/{id}/chunks/{cid}/slice   (post)

    public func getRevocationPartitionChunkSlice(for kid: String, id: String, cid: String, sids: [String]?,
            completion: @escaping ZIPDataTaskCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForChunkSlices.rawValue, kid, id, cid)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        
        let encoder = JSONEncoder()
        let postData = try? encoder.encode(sids)
        
        guard let request = RequestFactory.servicePostRequest(path: path, body: postData, etag: eTag) else {
            completion(nil, .badRequest(path: path))
            return
        }
        self.startZIPDataTask(for: request, completion: completion)
    }
    
    // MARK: - Single Slice content
    //summary: Returns for the selected chunk all content.
    //description: Returns a Partition by Id
    // paths:  /lists/{kid}/partitions/{id}/chunks/{cid}/slice/{sid} (get)
    
    public func getRevocationPartitionChunkSliceSingle(for kid: String, id: String, cid: String, sid: String,
            completion: @escaping ZIPDataTaskCompletion) {
        let partitionIDComponent = String(format: ServiceConfig.linkForSingleSlice.rawValue, kid, id, cid, sid)
        let path = baseServiceURLPath + partitionIDComponent
        guard let etagData = SecureKeyChain.load(key: "verifierETag") else { return }
        let eTag = String(decoding: etagData, as: UTF8.self)
        guard let request = RequestFactory.serviceGetRequest(path: path, etag: eTag) else {
            completion(nil, .badRequest(path: path))
            return
        }
        self.startZIPDataTask(for: request, completion: completion)
    }

    // private methods
    fileprivate func startJSONDataTask<T: Codable>(for request: URLRequest, completion: @escaping JSONDataTaskCompletion<T>) {
        let dataTask = session.dataTask(with: request) {[unowned self] (data, response, error) in
            guard error == nil else {
                completion(nil, nil, .network(reason: error!.localizedDescription))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, nil, .network(reason: "No HTTPURLResponse"))
                return
            }
            
            guard defaultResponseValidation(statusCode: httpResponse.statusCode) else {
                completion(nil, nil, .failedValidation(status: httpResponse.statusCode))
                return
            }
            
            guard let data = data else {
                completion(nil, nil, .nodata)
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
    
    fileprivate func startZIPDataTask(for request: URLRequest, completion: @escaping ZIPDataTaskCompletion) {
        let dataTask = session.dataTask(with: request) {[unowned self] (zipData, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, self.defaultResponseValidation(statusCode: httpResponse.statusCode) else {
                completion(nil, .failedValidation(status: (response as? HTTPURLResponse)?.statusCode ?? 0))
                return
            }
            guard error == nil else {
                completion(nil, RevocationError.network(reason: error!.localizedDescription))
                return
            }
            guard let zipData = zipData else {
                completion(nil, .nodata)
                return
            }
            completion(zipData, nil)
        }
        dataTask.resume()
    }

    fileprivate func defaultResponseValidation(statusCode: Int) -> Bool {
        switch statusCode {
        case 200:
            return true
        case 304:
            return false //.network(reason: "Not-Modified.")
        case 400, 404:
            return false //RevocationError.invalidID
        case 401:
            return false //RevocationError.unauthorized
        case 412:
            return false //RevocationError.network(reason: "Pre-Condition Failed.")
        default:
            return false //RevocationError.network(reason: "Failed with statusCode \(statusCode)")
        }
    }
}
