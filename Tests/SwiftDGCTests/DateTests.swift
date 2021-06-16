 //
//  Created by Steffen on 15.06.21.
//

import XCTest
import Foundation
@testable
import SwiftDGC

final class DateTests: XCTestCase {
    
    func testZuluTime(){
        let d = "2020-01-01"
        let date = Date(dateString: d)
        
        XCTAssert(date != nil)
    }
    
    func testOffSetTime(){
        let d = "2021-05-18T08:10:00+02:00"
        let date = Date(dateString: d)
        
        XCTAssert(date != nil)
    }
    
    func testDateTime(){
        let d = "2021-05-18T08:10:00"
        let date = Date(dateString: d)
        
        XCTAssert(date != nil)
    }
    
    func testYYMM(){
        let d = "2021-05"
        let date = Date(dateString: d)
        
        XCTAssert(date != nil)
    }
    
    func testYY(){
        let d = "2021"
        let date = Date(dateString: d)
        
        XCTAssert(date != nil)
    }
    
    func testFractionalTime(){
        let d = "2015-01-01T00:00:00.000Z"
        let date = Date(dateString: d)
        
        XCTAssert(date != nil)
    }
    
    
}
    
