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
//  Localization.swift
//
//
//  Created by Yannick Spreen on 5/6/21.
//

import Foundation

public var l10nModule: Bundle?

public func l10n(_ string: String, with comment: String? = nil, or fallback: String? = nil) -> String {
  var text = NSLocalizedString(string, comment: comment ?? "No comment provided.")
  if text != string {
    return text
  }
  text = NSLocalizedString(string, bundle: l10nModule ?? L10N.bundle, comment: comment ?? "No comment provided.")
  if text != string {
    return text
  }
  return fallback ?? string
}

public extension RawRepresentable where RawValue == String {
  var l10n: String {
    let key = "enum.\(String(describing: Self.self)).\(rawValue)"
    let text = NSLocalizedString(key, comment: "Automatic enum case.")
    if text != key {
      return text
    }
    return NSLocalizedString(key, bundle: l10nModule ?? L10N.bundle, comment: "Automatic enum case.")
  }
}

public func country(for code: String) -> String {
  l10n("country." + code, or: code)
}

class L10N {
  static var bundle: Bundle {
    #if SWIFT_PACKAGE
    Bundle.module
    #else
    Bundle(for: Self.self)
    #endif
  }
}
