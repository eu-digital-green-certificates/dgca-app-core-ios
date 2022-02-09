//
//  Extensions.swift
//  DCCRevocation
//
//  Created by Igor Khomiak on 02.02.2022.
//

import Foundation
import BigInt

extension Double {
    public var bytes: [UInt8] {
       withUnsafeBytes(of: self, Array.init)
   }
}

extension UInt16 {
    public var bytes: [UInt8] {
       withUnsafeBytes(of: self, Array.init)
   }
}

extension UInt32 {
    public var bytes: [UInt8] {
       withUnsafeBytes(of: self, Array.init)
   }
}

extension Int32 {
    public var bytes: [UInt8] {
       withUnsafeBytes(of: self, Array.init)
   }
}

extension Data {
    public var bytes: [UInt8] {
        return [UInt8](self)
    }
}

public extension Bytes {
      func toLong() -> UInt32 {
         let diff = 4-self.count
         var array: [UInt8] = [0,0,0,0]

          for idx in diff...3 {
              array[idx] = self[idx-diff]
          }

         return  UInt32(bigEndian: Data(array).withUnsafeBytes { $0.pointee })
     }
 }
