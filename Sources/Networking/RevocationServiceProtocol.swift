//
//  RevocationServiceProtocol.swift
//  
//
//  Created by Denis Melenevsky on 04.03.2022.
//

import Foundation

public protocol RevocationServiceProtocol {
    func getRevocationLists(completion: @escaping RevocationListCompletion)
    func getRevocationPartitions(for kid: String, completion: @escaping PartitionListCompletion)
    func getRevocationPartitions(for kid: String, id: String, completion: @escaping PartitionListCompletion)
    func getRevocationPartitionChunks(for kid: String, id: String, cids: [String]?, completion: @escaping ZIPDataTaskCompletion)
    func getRevocationPartitionChunk(for kid: String, id: String, cid: String, completion: @escaping ZIPDataTaskCompletion)
    func getRevocationPartitionChunkSlice(for kid: String, id: String, cid: String, sids: [String]?, completion: @escaping ZIPDataTaskCompletion)
    func getRevocationPartitionChunkSliceSingle(for kid: String, id: String, cid: String, sid: String, completion: @escaping ZIPDataTaskCompletion)
}
