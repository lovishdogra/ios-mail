//
//  CryptoTransformer.swift
//  ProtonMail - Created on 15/11/2018.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.


import Foundation
import Crypto

public class StringCryptoTransformer: CryptoTransformer {
    // String -> Data
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let string = value as? String else {
            return nil
        }
        
        do {
            let locked = try Locked<String>(clearValue: string, with: self.key)
            let result = locked.encryptedValue as NSData
            return result
        } catch let error {
            print(error)
            assert(false, "Error while encrypting value")
        }
        
        return nil
    }
    
    // Data -> String
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        
        let locked = Locked<String>(encryptedValue: data)
        do {
            let string = try locked.unlock(with: self.key)
            return string
        } catch let error {
            print(error)
            assert(false, "Error while decrypting value")
        }
        
        return nil
    }
}

public class CryptoTransformer: ValueTransformer {
    fileprivate var key: Keymaker.Key
    public init(key: Keymaker.Key) {
        self.key = key
    }
    
    public override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    public override class func allowsReverseTransformation() -> Bool {
        return true
    }
}
