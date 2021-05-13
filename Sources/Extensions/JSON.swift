//
//  File.swift
//  
//
//  Created by Yannick Spreen on 5/12/21.
//

import SwiftyJSON

public extension JSON {
  init(parseJSONC json: String) {
    let json = json.replacingOccurrences(of: "\r", with: "\n").split(separator: "\n").filter {
      !$0.trimmingCharacters(in: [" ", "\t"]).starts(with: "//")
    }.joined(separator: "\n")
    self = JSON(parseJSON: json)
  }

  mutating func merge(other: JSON) {
    if self.type == other.type {
      switch self.type {
      case .dictionary:
        for (key, _) in other {
          self[key].merge(other: other[key])
        }
      default:
        self = other
      }
    } else {
      self = other
    }
  }

  func mergeAndOverride(other: JSON) -> JSON {
    var merged = self
    merged.merge(other: other)
    return merged
  }
}
