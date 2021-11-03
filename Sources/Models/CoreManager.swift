//
//  CoreManager.swift
//  
//
//  Created by Igor Khomiak on 21.10.2021.
//

import UIKit
import SwiftyJSON

public class CoreManager {
    public static var shared = CoreManager()
    public static var cachedQrCodes = [String: UIImage]()
    public static var publicKeyEncoder: PublicKeyStorageDelegate?

    lazy public var config = HCertConfig.default
}
