import XCTest
@testable import SwiftDGC

#if SWIFT_PACKAGE
let inPackage = true
#else
let inPackage = false
#endif

final class SwiftDGCTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.

    let bundle: Bundle = inPackage ? .module : Bundle(for: type(of: self))

    guard
      var path = bundle.resourcePath
    else {
      return
    }
    path += "/dgc-testdata"
    guard
      let contents = try? FileManager.default.contentsOfDirectory(atPath: path)
    else {
      return
    }

    print(contents)
  }

  static var allTests = [
    ("testExample", testExample)
  ]
}
