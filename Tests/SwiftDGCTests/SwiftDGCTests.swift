import XCTest
@testable
import SwiftDGC
import SwiftyJSON

var bundle: Bundle!
#if SWIFT_PACKAGE
let inPackage = true
var bundle = Bundle.module
#else
let inPackage = false
#endif

enum ValidationErrors: Error {
  case invalidHCert
}

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
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.

    bundle = bundle ?? Bundle(for: type(of: self))
    l10nModule = bundle

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
      try? test(jsonFile: path)
    }
  }

  func test(jsonFile path: String) throws {
    let url = URL(fileURLWithPath: path)
    guard
      let data = try? Data(contentsOf: url),
      let string = String(data: data, encoding: .utf8)
    else {
      fatalError()
    }
    let json = JSON(parseJSON: string)
    guard let hcert = HCert(from: json["PREFIX"].string ?? "") else {
      throw ValidationErrors.invalidHCert
    }
    print(hcert)
  }

  static var allTests = [
    ("testExample", testExample)
  ]
}
