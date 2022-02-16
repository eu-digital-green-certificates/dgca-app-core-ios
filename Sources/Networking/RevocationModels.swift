//
//  RevocationModels.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 21.01.2022.
//

import Foundation

public typealias SliceDict = [String : SliceModel]

public struct RevocationModel: Hashable, Codable {
    public let kid: String
    public let mode: String
    public let hashTypes: [String]
    public let expires: String
    public let lastUpdated: String
}


public struct PartitionModel: Hashable, Codable {
    public let kid: String
    public var id: String?
    public var x: String?
    public var y: String?
    public let lastUpdated: String
    public let expired: String
    public let chunks: [String : SliceDict]
}

public struct SliceModel: Hashable, Codable {
    public let type: String
    public let version: String
    public let hash: String
}

public struct SliceMetaData {
    public let kid: String
    public let id: String
    public let cid: String
    public let hashID: String
    public let contentData: Data
    
    public init(kid: String, id: String, cid: String, hashID: String, contentData: Data) {
        self.kid = kid
        self.id = id
        self.cid = cid
        self.hashID = hashID
        self.contentData = contentData
    }
}
