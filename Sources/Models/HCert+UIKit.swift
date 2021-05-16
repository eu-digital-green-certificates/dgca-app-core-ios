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
//  HCert+UIKit.swift
//
//
//  Created by Yannick Spreen on 4/19/21.
//

#if os(iOS)
import UIKit

extension HCert {
  var qrCodeRendered: UIImage? {
    cachedQrCodes[uvci]
  }

  public var qrCode: UIImage? {
    return qrCodeRendered ?? renderQrCode()
  }

  func renderQrCode() -> UIImage? {
    if let rendered = qrCodeRendered {
      return rendered
    }
    let code = makeQrCode()
    if let value = code {
      Self.qrLock.lock()
      cachedQrCodes[uvci] = value
      Self.qrLock.unlock()
    }
    return code
  }

  func makeQrCode() -> UIImage? {
    let data = payloadString.data(using: String.Encoding.ascii)

    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)

      if let output = filter.outputImage?.transformed(by: transform) {
        return UIImage(ciImage: output)
      }
    }

    return nil
  }

  func prefetchCode() {
    guard qrCodeRendered == nil else {
      return
    }
    DispatchQueue.global(qos: .background).async {
      _ = renderQrCode()
    }
  }
}

var cachedQrCodes = [String: UIImage]()
#endif
