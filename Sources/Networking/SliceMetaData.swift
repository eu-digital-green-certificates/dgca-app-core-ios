//
//  SliceMetaData.swift
//  
//
//  Created by Igor Khomiak on 20.02.2022.
//

import Foundation

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
