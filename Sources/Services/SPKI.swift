/*
 
 Based on https://github.com/datatheorem/TrustKit/blob/master/TrustKit/Pinning/TSKSPKIHashCache.m
 
 The MIT License (MIT)

 Copyright (c) 2015 Data Theorem, Inc.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

import CommonCrypto
import Foundation

enum SPKI {
    case rsa2048
    case rsa4096
    case ecDsaSecp256r1
    case ecDsaSecp384r1
    
    // These are the ASN1 headers for the Subject Public Key Info section of a certificate
    var asn1Header: Data {
        switch self {
        case .rsa2048:
            return .init([
                0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
            ])
            
        case .rsa4096:
            return .init([
                0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
            ])
            
        case .ecDsaSecp256r1:
            return .init([
                0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
                0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
                0x42, 0x00
            ])
            
        case .ecDsaSecp384r1:
            return .init([
                0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
                0x01, 0x06, 0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
            ])
        }
    }
    
    static func create(from publicKey: SecKey) -> Self? {
        guard let publicKeyAttributes = SecKeyCopyAttributes(publicKey) as? [CFString: Any],
              let publicKeyType = publicKeyAttributes[kSecAttrKeyType] as? String,
              let publicKeySize = publicKeyAttributes[kSecAttrKeySizeInBits] as? Int
              else { return nil }
        
        if publicKeyType == kSecAttrKeyTypeRSA as String && publicKeySize == 2048 {
            return .rsa2048
        }
        
        if publicKeyType == kSecAttrKeyTypeRSA as String && publicKeySize == 4096 {
            return .rsa4096
        }

        if publicKeyType == kSecAttrKeyTypeECSECPrimeRandom as String && publicKeySize == 256 {
            return .ecDsaSecp256r1
        }

        if publicKeyType == kSecAttrKeyTypeECSECPrimeRandom as String && publicKeySize == 384 {
            return .ecDsaSecp384r1
        }
        
        return nil
    }
    
    static func extract(from publicKey: SecKey) -> Data? {
        guard let spki = create(from: publicKey),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
        else { return nil }
        
        return spki.asn1Header + publicKeyData
    }
}
