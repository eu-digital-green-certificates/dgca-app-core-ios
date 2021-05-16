import XCTest
@testable
import SwiftDGC
import SwiftyJSON

#if SWIFT_PACKAGE
let inPackage = true
#else
let inPackage = false
#endif

let bundle = inPackage ? .module : Bundle(for: SwiftDGCTests.self)

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
  func testCases() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.

    l10nModule = bundle

    XCTAssert(l10n("btn.cancel") != "btn.cancel", "l10n failed")

    HCert.publicKeyStorageDelegate = self

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
    fileName = String(path.split(separator: "/").last ?? "")
    guard
      let data = try? Data(contentsOf: url),
      let string = String(data: data, encoding: .utf8)
    else {
      XCTAssert(false, "cannot decode \(descr)")
      return
    }
    json = JSON(parseJSON: string)
    HCert.clockOverride = clock
    guard let hcert = HCert(from: payloadString ?? "") else {
      return
    }
//    print(hcert)
  }

  var json: JSON?

  var payloadString: String? {
    json?["PREFIX"].string
  }
  var context: JSON {
    json?["TESTCTX"] ?? .null
  }
  var certString: String? {
    context["CERTIFICATE"].string
  }
  var fileName: String?
  var descr: String {
    context["DESCRIPTION"].string ?? fileName ?? ""
  }
  var clock: Date? {
    Date(rfc3339DateTimeString: context["VALIDATIONCLOCK"].string ?? "")
  }
  var expected: JSON {
    json?["EXPECTEDRESULTS"] ?? .null
  }
  var expValidObject: Bool {
    expected["EXPECTEDVALIDOBJECT"].bool ?? true
  }
  var expSchemaValidation: Bool {
    expected["EXPECTEDSCHEMAVALIDATION"].bool ?? true
  }
  var expDecode: Bool {
    expected["EXPECTEDDECODE"].bool ?? true
  }
  var expVerify: Bool {
    expected["EXPECTEDVERIFY"].bool ?? true
  }
  var expUnprefix: Bool {
    expected["EXPECTEDUNPREFIX"].bool ?? true
  }
  var expValidJson: Bool {
    expected["EXPECTEDVALIDJSON"].bool ?? true
  }
  var expCompression: Bool {
    expected["EXPECTEDCOMPRESSION"].bool ?? true
  }
  var expB45decode: Bool {
    expected["EXPECTEDB45DECODE"].bool ?? true
  }
  var expPicturedecode: Bool {
    expected["EXPECTEDPICTUREDECODE"].bool ?? true
  }

  static var allTests = [
    ("testCases", testCases)
  ]
}

extension SwiftDGCTests: PublicKeyStorageDelegate {
  func getEncodedPublicKeys(for _: String) -> [String] {
    [certString ?? ""]
  }
}
