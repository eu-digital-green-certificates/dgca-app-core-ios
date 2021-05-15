import XCTest
@testable import SwiftDGC

#if SWIFT_PACKAGE
let inPackage = true
#else
let inPackage = false
#endif

func ls(path: String) -> [String] {
  (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
}

func isDir(path: String) -> Bool {
  var isDirectory: ObjCBool = false
  let exists = FileManager.default.fileExists(
    atPath: path,
    isDirectory: &isDirectory
  )
  return exists && isDirectory.boolValue
}

final class SwiftDGCTests: XCTestCase {
  var bundle: Bundle { inPackage ? .module : Bundle(for: type(of: self)) }

  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.

    guard
      var path = bundle.resourcePath
    else {
      return
    }
    path += "/dgc-testdata"
    let contents = ls(path: path).filter {
      isDir(path: "\(path)/\($0)") && !$0.hasPrefix(".")
    }
    for country in contents.sorted() {
      testCountry(dir: "\(path)/\(country)", for: country)
    }
  }

  func testCountry(dir: String, for countryName: String) {
    print("Testing", countryName)
    guard isDir(path: "\(dir)/2DCode/raw") else {
      return
    }
    for file in ls(path: "\(dir)/2DCode/raw") {
      let path = "\(dir)/2DCode/raw/\(file)"
      print(path)
    }
  }

  static var allTests = [
    ("testExample", testExample)
  ]
}
