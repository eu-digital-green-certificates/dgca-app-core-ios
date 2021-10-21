//
//  File.swift
//  
//
//  Created by Igor Khomiak on 21.10.2021.
//

import Foundation
import SwiftyJSON

public class VerificationManager {
    public static var sharedManager = VerificationManager()

    public var config = HCertConfig()
    public var publicKeyStorageDelegate: PublicKeyStorageDelegate?

}
