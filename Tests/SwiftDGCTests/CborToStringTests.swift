//
//  File.swift
//  
//
//  Created by Steffen on 28.06.21.
//

import Foundation
import XCTest

@testable
import SwiftDGC
import SwiftCBOR


final class CborToStringTest: XCTestCase {
    
    func testNormal()
    {
        let test = "Hello";
        let cbor = SwiftCBOR.CBOR.init(stringLiteral: test)
        let toStr = cbor.toString()
        XCTAssertTrue(toStr == "\"Hello\"")
    }
    
    func testEnqouting()
    {
        let test = "\"Hello\"";
        let cbor = SwiftCBOR.CBOR.init(stringLiteral: test)
        let toStr = cbor.toString()
        XCTAssertTrue(toStr == "\"\\\"Hello\\\"\"")
    }
}
