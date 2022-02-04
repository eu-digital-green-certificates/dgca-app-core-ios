//
//  RevocationModels.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 21.01.2022.
//

import Foundation

public typealias SliceDict = [String : SliceModel]

public struct RevocationModel: Codable {
    public var kid: String
    public let mode: String
    public let hashType: [String]
    public let expires: String
    public let lastUpdated: String
}


public struct PartitionModel: Codable {
    public let id: String?
    public let x: String?
    public let y: String?
    public let expires: String
    public var chunks: [String : SliceDict]
}

public struct SliceModel: Codable {
    public let type: String
    public let version: String
    public let hash: String
}
