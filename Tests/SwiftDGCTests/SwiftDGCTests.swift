/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//
//  SwiftDGCTests.swift
//
//
//  Created by Yannick Spreen on 5/16/21.
//

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

    if l10n("btn.cancel") == "btn.cancel" {
      XCTAssert(false, "l10n failed")
      return
    }

    HCert.publicKeyStorageDelegate = self
    HCert.debugPrintJsonErrors = false

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
    let error = HCert.ParseErrors()
    let hcert = HCert(from: payloadString ?? "", errors: error)
    let errors = error.errors

    for error in errors {
      switch error {
      case .base45:
        XCTAssert(expB45decode != true, "unexpected base45 err for \(descr)")
      case .prefix:
        XCTAssert(expUnprefix != true, "unexpected prefix err for \(descr)")
      case .zlib:
        XCTAssert(expCompression != true, "unexpected zlib err for \(descr)")
      case .cbor:
        XCTAssert(expDecode != true, "unexpected cbor err for \(descr)")
      case .json(error: let error):
        XCTAssert(expSchemaValidation != true, "unexpected schema err for \(descr): \(error)")
      case .version:
        XCTAssert(expSchemaValidation != true, "unexpected version err for \(descr)")
      }
    }
    guard let hcert = hcert else {
      return
    }
    checkHcert(hcert: hcert)
  }

  func checkHcert(hcert: HCert) {
    let kidMatches = hcert.kidStr == KID.string(from: KID.from(certString ?? ""))
    let valid = kidMatches && hcert.cryptographicallyValid

    if expVerify == true {
      XCTAssert(hcert.cryptographicallyValid, "cose signature invalid for \(descr)")
      XCTAssert(kidMatches, "cose KID mismatch for \(descr)")
    } else if expVerify == false {
      XCTAssert(!valid, "cose signature valid for \(descr)")
    }
    if expExpired == true {
      XCTAssert(clock != nil, "clock not set for \(descr)")
      XCTAssert(!hcert.validityFailures.contains(l10n("hcert.err.exp")), "cose expired for \(descr)")
    } else if expExpired == false {
      XCTAssert(clock != nil, "clock not set for \(descr)")
      XCTAssert(hcert.validityFailures.contains(l10n("hcert.err.exp")), "cose not expired for \(descr)")
    }
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
    if let description = context["DESCRIPTION"].string {
      return "\(fileName ?? "") (\(description))"
    }
    return "\(fileName ?? "")"
  }
  var clock: Date? {
    Date(rfc3339DateTimeString: context["VALIDATIONCLOCK"].string ?? "")
  }
  var expected: JSON {
    json?["EXPECTEDRESULTS"] ?? .null
  }
  var expValidObject: Bool? {
    expected["EXPECTEDVALIDOBJECT"].bool
  }
  var expSchemaValidation: Bool? {
    expected["EXPECTEDSCHEMAVALIDATION"].bool
  }
  var expDecode: Bool? {
    expected["EXPECTEDDECODE"].bool
  }
  var expVerify: Bool? {
    expected["EXPECTEDVERIFY"].bool
  }
  var expUnprefix: Bool? {
    expected["EXPECTEDUNPREFIX"].bool
  }
  var expValidJson: Bool? {
    expected["EXPECTEDVALIDJSON"].bool
  }
  var expCompression: Bool? {
    expected["EXPECTEDCOMPRESSION"].bool
  }
  var expB45decode: Bool? {
    expected["EXPECTEDB45DECODE"].bool
  }
  var expPicturedecode: Bool? {
    expected["EXPECTEDPICTUREDECODE"].bool
  }
  var expExpired: Bool? {
    expected["EXPECTEDEXPIRATIONCHECK"].bool
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
